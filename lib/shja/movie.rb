require 'fastimage'

class Shja::MovieManager < Shja::ManagerBase
  attr_reader :actors

  def initialize(db, actors)
    super(db)
    @actors = actors
  end

  def all
    self.db.movies.each do |movie|
      movie.actor = actors.find(movie.actor_id)
      yield movie
    end
  end

  def find(id)
    self.db.movies.find{|e| e['id'] == id }.tap do |movie|
      raise "Movie not found: #{id}" unless movie
      movie.actor = actors.find(movie.actor_id)
    end
  end

  def find_by_actor(actor)
    self.db.movies.select { |e| e.actor_id == actor.id }
                  .map { |e| e.actor = actor; e }
  end

  def update(movie)
    actor = actors.find(movie.actor_id)
    _movie = self.db.movies.find{|e| e == movie }
    if _movie
      _movie.actor = actor
      _movie.data_hash.update(movie.to_h)
    else
      movie.actor = actor
      self.db.movies << movie
    end
  end

end

class Shja::Movie < Shja::ResourceBase
  # attr_reader :id
  # attr_reader :actor_id
  # attr_reader :title
  # attr_reader :url
  # attr_reader :photoset_url
  # attr_reader :thumbnail
  # attr_reader :date
  # attr_reader :zip
  # attr_reader :formats
  attr_reader :actor

  def actor=(actor)
    self['actor_id'] = actor.id
    @actor = actor
  end

  def download(agent, format=nil)
    download_thumbnail(agent)
    download_photoset(agent)
    download_movie(agent, format)
  end

  def download_movie(agent, format)
    unless format
      Shja::log.info("format isn't specified for: #{self.id}")
      return
    end
    unless url = self.formats[format]
      Shja::log.warn("movie not found in formats: #{format}")
      Shja::log.debug("formats: #{self.formats}")
      return
    end
    self._download(agent, url, movie_path(format))
  end

  def download_photoset(agent)
    Shja::log.debug("Start download photoset: #{self.id}")
    # if has_pictures?
    #   Shja::log.debug("Movie has already photoset")
    #   return
    # end
    page = agent._fetch_page(self.photoset_url)
    parser = Shja::Parser::HcZipPage.new(page)
    result = parser.parse_pictures
    _download_pictures(agent, result[:pictures])
    result[:pages].each do |url|
      page = agent._fetch_page(url)
      parser = Shja::Parser::HcZipPage.new(page)
      _download_pictures(agent, parser.parse_pictures[:pictures])
    end
  end

  def download_thumbnail(agent)
    Shja::log.debug("Start download thumbnail: #{self.id}")
    self._download(agent, self.thumbnail, self.thumbnail_path)
  end

  def pictures_path
    Dir.glob(File.join(photoset_dir_path, '*.jpg'))
  end

  def has_pictures?
    pictures_path.size > 0
  end

  def pictures_metadata
    return pictures_path.sort.map do |image|
      basename = File.basename(image)
      size = ::FastImage.size(image)
      if size
        {
          "name" => basename,
          "w" => size[0],
          "h" => size[1]
        }
      else
        Shja::log.warn("Image can't detect size: #{image}")
        nil
      end.compact
    end
  end

  def photoset_dir_path
    File.join(self.actor.target_dir, self.photoset_dir_url)
  end

  def photoset_dir_url
    File.join(self.dir_url, "photoset")
  end

  def picture_path(url)
    basename = File.basename(url)
    File.join(self.photoset_dir_path, basename)
  end

  def movie_exist?(format)
    File.file?(movie_path(format))
  end

  def movie_path(format)
    File.join(self.actor.target_dir, self.movie_url(format))
  end

  def movie_url(format)
    File.join(self.dir_url, "#{format}.mp4")
  end

  def thumbnail_path
    File.join(self.actor.target_dir, self.thumbnail_url)
  end

  def thumbnail_url
    File.join(self.dir_url, 'thumbnail.jpg')
  end

  def dir_path
    File.join(self.actor.target_dir, self.dir_url)
  end

  def dir_url
    File.join(self.actor.dir_url, self.id)
  end

  def _download_pictures(agent, pictures)
    pictures.each do |url|
      self._download(agent, url, picture_path(url))
    end
  end
end
