
class Shja::MovieManager::Pondo < Shja::MovieManager

  def download_index(start_page: 0, last_page: 0)
    return [].tap do |movie_ids|
      (start_page..last_page).each do |index|
        url = "http://www.1pondo.tv/dyn/ren/movie_lists/list_newest_#{index * 50}.json"
        parse_index_page(url)
      end
      db.save
    end
  end

  def download_actor_index(actor_id)
    url = "http://www.1pondo.tv/dyn/ren/movie_lists/actresses/list_#{actor_id}_0.json"
    parse_index_page(url)
    db.save
  end

  def parse_index_page(url)
    movies = JSON.load(agent.fetch_page(url))
    movies['Rows'].each do |movie|
      movie = Shja::Movie::Pondo.new(context, movie)
      self.update(movie)
      movie.download_metadata
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

class Shja::Movie::Pondo < Shja::Movie

  def id
    return self.movie_id
  end

  def download(format)
    Shja.log.info("Download start: #{title}, #{dir_url}")
    download_metadata
    download_photoset
    return download_movie(format)
  end

  def download_metadata
    mkdir
    self._download(metadata_remote_url, metadata_url, ignore_error: true)
    self._download(photoset_metadata_remote_url, photoset_metadata_url, ignore_error: true)
    # self._download(movie_thumb, thumbnail_url)

    self._download(thumb_high, thumbnail_url('high'), ignore_error: true)
    self._download(thumb_low, thumbnail_url('low'), ignore_error: true)
    self._download(thumb_med, thumbnail_url('med'), ignore_error: true)
    self._download(thumb_ultra, thumbnail_url('ultra'), ignore_error: true)

    create_thumbnail
  end

  def default_format
    return detail.default_format
  end

  def exists?(format=nil)
    format = detail.default_format
    movie_path = to_path(movie_url(format))

    File.file?(movie_path)
  end

  def download_movie(format=nil)
    format = detail.default_format
    detail.download(to_path(movie_url(format)), format)
  end

  def download_photoset
    photosets.download(to_path(photoset_dir_url))
  end

  def pictures_path
    Dir.glob(File.join(to_path(photoset_dir_url), '*.jpg'))
  end

  def create_thumbnail
    real_from_path = to_path(thumbnail_url('med'))
    return unless File.file?(real_from_path)
    real_tb_path = to_path(thumbnail_url)
    unless File.file?(real_tb_path)
      Shja.log.debug("Creating thumbnail from: #{real_from_path}")
      Shja.log.debug("Creating thumbnail to: #{real_tb_path}")
      Speedpetal::resize(480, real_from_path, real_tb_path)
    end
  end

  def actor?(name)
    return actor.include?(name)
  end

  def detail
    @detail ||= Shja::Movie::Pondo::Detail.new(context, to_path(metadata_url))
    @detail
  end

  def photosets
    @photosets ||= Shja::Movie::Pondo::Photosets.new(context, to_path(photoset_metadata_url))
    @photosets
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

  def movie_url(format)
    return "#{dir_url}-#{format}.mp4"
  end

  def photoset_dir_url
    return "#{dir_url}/photoset"
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

class Shja::Movie::Pondo::DetailBase < Shja::ResourceBase
  def initialize(context, path)
    data_hash = nil
    begin
      data_hash = open(path) do |io|
        data_hash = JSON.load(io.read)
      end
    rescue Errno::ENOENT => ex
      Shja.log.warn("Data couldn't be loaded: #{path}")
      data_hash = {}
    end
    super(context, data_hash)
  end
end

class Shja::Movie::Pondo::Detail < Shja::Movie::Pondo::DetailBase
  def remote_url(format)
    movie = data_hash["MemberFiles"].find do |file|
      file["FileName"] == "#{format}.mp4"
    end
    movie = {} unless movie
    return [movie["URL"], movie["FileSize"]]
  end

  def download(path, format=default_format)
    unless File.file?(path)
      url, size = remote_url(format)
      Shja.log.debug("Download Movie: #{url}")
      agent.download(url, path)
      if File.size(path) < size
        raise "File size is invalid, actual: #{File.size(path)}, expected: #{size}"
      end
      return true
    end
    return false
  end

  def formats
    data_hash["MemberFiles"].map do |file|
      File.basename(file["FileName"], '.*')
    end
  end

  def default_format
    f = formats.map do |file|
      file.to_i
    end.sort[-1]
    return "#{f}p"
  end
end

class Shja::Movie::Pondo::Photosets < Shja::Movie::Pondo::DetailBase

  def download(dir)
    unless data_hash["Rows"]
      Shja::log.info("No data")
    end
    FileUtils.mkdir_p(dir)

    data_hash["Rows"].each_with_index do |img, index|
      begin
        url = img["URL"]
        index = sprintf("%03d", index)
        agent.download(url, File.join(dir, "#{index}.jpg"))
      rescue => ex
        Shja.log.error(ex.message)
      end
    end
  end
end
