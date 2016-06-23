require 'json'

class Shja::MovieManager::Pondo < Shja::ManagerBase

  def initialize(context)
    super
    context.movies = self
  end

  def download_index(start_page: 0, last_page: 0)
    return [].tap do |movie_ids|
      (start_page..last_page).each do |index|
        url = "http://www.1pondo.tv/dyn/ren/movie_lists/list_newest_#{index * 50}.json"
        movies = JSON.load(agent.fetch_page(url))
        movies['Rows'].each do |movie|
          movie = Shja::Movie::Pondo.new(context, movie)
          self.update(movie)
          movie.download_metadata
          movie_ids << movie[movie_id_key]
        end
      end
      db.save
    end
  end

  def movie_id_key
    return 'MovieID'
  end

  def find(id)
    Shja::Movie::Pondo.new(context, _find(id))
  end

  def all
    _all do |movie|
      yield Shja::Movie::Pondo.new(context, movie)
    end
  end

end

class Shja::Movie::Pondo < Shja::ResourceBase

  def download_metadata
    mkdir
    self._download(metadata_remote_url, metadata_url)
    self._download(photoset_metadata_remote_url, photoset_metadata_url)
    self._download(movie_thumb, thumbnail_url)

    self._download(thumb_high, thumbnail_url('high'))
    self._download(thumb_low, thumbnail_url('low'))
    self._download(thumb_med, thumbnail_url('med'))
    self._download(thumb_ultra, thumbnail_url('ultra'))
  end

  def mkdir
    dir_path = to_path(:dir_url)
    unless File.directory?(dir_path)
      FileUtils.mkdir_p(dir_path)
    end
  end

  def _download(from, to)
    if from.kind_of?(Symbol)
      from = self.send(from)
    end
    to = to_path(to)
    unless File.file?(to)
      agent.download(from, to)
    end
  rescue => ex
    Shja.log.error("Download failed: #{from}")
    FileUtils.rm(to)
  end

  def metadata_remote_url
    "http://www.1pondo.tv/dyn/ren/movie_details/#{self['MetaMovieID']}.json"
  end

  def photoset_metadata_remote_url
    "http://www.1pondo.tv/dyn/ren/movie_galleries/#{self['MetaMovieID']}.json"
  end

  def metadata_url
    return "#{dir_url}/metadata.json"
  end

  def photoset_metadata_url
    return "#{dir_url}/photoset_metadata.json"
  end

  def thumbnail_url(format=nil)
    if format
      return "#{dir_url}/tb_#{format}.jpg"
    else
      return "#{dir_url}.jpg"
    end
  end

  def dir_url
    return "#{top_dir_url}/#{movie_id}"
  end

  def top_dir_url
    return self.release.split('-')[0, 2].join('-')
  end

  def to_path(url_sym_or_str)
    if url_sym_or_str.kind_of?(Symbol)
      url_sym_or_str = self.send(url_sym_or_str)
    end
    return File.join(target_dir, url_sym_or_str)
  end

  def method_missing(method_sym, *arguments, &block)
    if @data_hash.include? camelize(method_sym.to_s)
      @data_hash[camelize(method_sym.to_s)]
    else
      super
    end
  end

  def respond_to?(method_sym, include_private = false)
    if @data_hash.include? camelize(method_sym.to_s)
      true
    else
      super
    end
  end

  def acronyms
    {
      'id' => 'ID',
      'uc' => 'UC',
      'name' => 'NAME',
    }
  end

  def camelize(term)
    string = term.to_s
    string = string.sub(/^[a-z\d]*/) { acronyms[$&] || $&.capitalize }
    string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{acronyms[$2] || $2.capitalize}" }
    string.gsub!(/\//, '::')
    string
  end

end
