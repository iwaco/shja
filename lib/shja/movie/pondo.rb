
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

  def actor_index_url(actor_id, index)
    "http://www.1pondo.tv/dyn/ren/movie_lists/actresses/list_#{actor_id}_#{index * 50}.json"
  end

  def download_actor_index(actor_id)
    _download_index_by_id(:actor_index_url, actor_id)
  end

  def series_index_url(series_id, index)
    "http://www.1pondo.tv/dyn/ren/movie_lists/series/list_#{series_id}_#{index * 50}.json"
  end

  def download_series_index(series_id)
    _download_index_by_id(:series_index_url, series_id)
  end

  def _download_index_by_id(url_sym, id)
    url = send(url_sym, id, 0)
    total_rows = parse_index_page(url)
    index = 1
    until total_rows < (index * 50)
      url = send(url_sym, id, index)
      parse_index_page(url)
      index += 1
    end
    db.save
  end

  def parse_index_page(url)
    Shja.log.info("Fetch Actor Index: #{url}")
    movies = JSON.load(agent.fetch_page(url))
    movies['Rows'].each do |movie|
      movie = Shja::Movie::Pondo.new(context, movie)
      self.update(movie)
      movie.download_metadata
    end
    return movies['TotalRows']
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
    return download_movie(format)
  end

  def download_metadata
    mkdir
    self._download(metadata_remote_url, metadata_url, ignore_error: true)
    self._download(new_metadata_remote_url, metadata_url, ignore_error: true)
    self._download(photoset_metadata_remote_url, photoset_metadata_url, ignore_error: true)
    self._download(new_photoset_metadata_remote_url, photoset_metadata_url, ignore_error: true)
    # self._download(movie_thumb, thumbnail_url)

    self._download(thumb_high, thumbnail_url('high'), ignore_error: true)
    self._download(thumb_low, thumbnail_url('low'), ignore_error: true)
    self._download(thumb_med, thumbnail_url('med'), ignore_error: true)
    self._download(thumb_ultra, thumbnail_url('ultra'), ignore_error: true)

    download_photoset
    create_thumbnail
  end

  def default_format
    return detail.default_format
  end

  def download_movie(format=nil)
    format = detail.default_format
    detail.download(format)
  end

  def download_photoset
    photosets.download_from_zip
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
    @detail ||= Shja::Movie::Pondo::Detail.new(self, to_path(metadata_url))
    @detail
  end

  def photosets
    @photosets ||= Shja::Movie::Pondo::Photosets.new(self, to_path(photoset_metadata_url))
    @photosets
  end

  def page_remote_url
    "http://www.1pondo.tv/movies/#{self.meta_movie_id}/"
  end

  def metadata_remote_url
    "http://www.1pondo.tv/dyn/ren/movie_details/#{self.meta_movie_id}.json"
  end

  def photoset_metadata_remote_url
    "http://www.1pondo.tv/dyn/ren/movie_galleries/#{self.meta_movie_id}.json"
  end

  def new_metadata_remote_url
    "http://www.1pondo.tv/dyn/ren/movie_details/movie_id/#{self.movie_id}.json"
  end

  def new_photoset_metadata_remote_url
    "http://www.1pondo.tv/dyn/ren/movie_galleries/movie_id/#{self.movie_id}.json"
  end

  def metadata_url
    return "#{dir_url}/metadata.json"
  end

  def movie_url(format)
    return "#{dir_url}-#{format}.mp4"
  end

  def zip_url
    return "#{dir_url}.zip"
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
  attr_reader :movie

  def initialize(movie, path)
    @movie = movie
    data_hash = nil
    begin
      data_hash = open(path) do |io|
        data_hash = JSON.load(io.read)
      end
    rescue Errno::ENOENT => ex
      Shja.log.warn("Data couldn't be loaded: #{path}")
      data_hash = {}
    end
    super(movie.context, data_hash)
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

  def download(format=default_format)
    movie_url = movie.movie_url(format)
    movie_path = movie.to_path(movie_url)
    url, size = remote_url(format)
    Shja.log.info("Download Movie: #{self.movie.title}, #{url}")
    if movie._download(url, movie_url, ignore_error: true)
      if File.size(movie_path) < size
        Shja.log.warn("File size is invalid, actual: #{File.size(movie_path)}, expected: #{size}")
      end
      return true
    else
      return false
    end
  end

  def formats
    data_hash["MemberFiles"].map do |file|
      File.basename(file["FileName"], '.*')
    end
  rescue
    Shja.log.warn("There are no formats: #{movie.page_remote_url} #{movie.title}")
    return {}
  end

  def default_format
    f = formats.map do |file|
      file.to_i
    end.sort[-1]
    return "#{f}p"
  end
end

class Shja::Movie::Pondo::Photosets < Shja::Movie::Pondo::DetailBase

  def zip_remote_url
    zip_remote_path = agent.find_attribute(
      movie.page_remote_url,
      "movie-details movie-action-panel .ng-scope a",
      "href"
    )
    return "http://www.1pondo.tv#{zip_remote_path}"
  end

  def download
    # FIXME: implements later
    return
    dir = movie.to_path(movie.photoset_dir_url)
    unless data_hash["Rows"]
      Shja::log.info("No data: #{movie.title}")
      return
    end
    Shja.log.info("Download Photoset: #{movie.title}, #{dir}")
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

  def download_from_zip
    # XXX: Skip downloading zip
    return
    unless movie['HasMemberGalleryZip']
      Shja::log.debug("No zip: #{movie.title}")
    end
    _zip_remote_url = zip_remote_url
    Shja.log.debug("Download zip: #{_zip_remote_url}, #{movie.zip_url}")
    movie._download(_zip_remote_url, movie.zip_url, ignore_error: true)
    movie.extract_zip
  rescue => ex
    Shja.log.error(ex.message)
    Shja.log.error(ex.backtrace.join("\n"))
  end
end
