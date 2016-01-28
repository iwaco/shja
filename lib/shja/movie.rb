
class Shja::MovieManager < Shja::ManagerBase
  attr_reader :actors

  def initialize(db, actors)
    super(db)
    @actors = actors
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
    download_movie(format)
  end

  def download_movie(format)
    unless format
      Shja::log.info("format isn't specified for: #{self.id}")
    end
    unless url = self.formats['format']
      Shja::log.warn("movie not found in formats: #{format}")
      Shja::log.debug("formats: #{self.formats}")
    end
    self._download(agent, url, movie_path(format))
  end

  def download_photoset(agent)
    Shja::log.debug("Start download photoset: #{self.id}")
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

  def photoset_dir_path
    File.join(self.dir_path, "photoset")
  end

  def picture_path(url)
    basename = File.basename(url)
    File.join(self.photoset_dir_path, basename)
  end

  def movie_path(format)
    File.join(self.dir_path, "#{format}.mp4")
  end

  def thumbnail_path
    File.join(self.dir_path, 'thumbnail.jpg')
  end

  def dir_path
    File.join(self.actor.dir_path, self.id)
  end

  def _download_pictures(agent, pictures)
    pictures.each do |url|
      self._download(agent, url, picture_path(url))
    end
  end
end
