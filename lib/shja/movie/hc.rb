
class Shja::MovieManager::Hc < Shja::MovieManager
  def_delegators :@context, :actors

  def all
    self.db.movies.each do |movie|
      movie.actor = actors.find(movie.actor_id)
      yield movie
    end
  end

  def movie_id_key
    return 'id'
  end

  def find(id)
    self.db.movies.find{|e| e[movie_id_key] == id }.tap do |movie|
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
    movie.actor = actor
    if _movie
      _movie.data_hash.update(movie.to_h)
    else
      self.db.movies << movie
    end
  end

end

class Shja::Movie::Hc < Shja::Movie
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

  def initialize(data_hash)
    super(nil, data_hash)
  end

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
    self._download(url, movie_path(format))
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
    self._download(self.thumbnail, self.thumbnail_path)
  end

  def pictures_path
    Dir.glob(File.join(photoset_dir_path, '*.jpg'))
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

module Shja::ActorManager; end

class Shja::ActorManager::Hc < Shja::ManagerBase

  def initialize(context)
    super(context)
    context.actors = self
    @actor_cache = {}
  end

  def find(id)
    actor = @actor_cache[id]
    return actor if actor
    return self.db.actors.find{|e| e['id'] == id }.tap do |actor|
      raise "Actor not found: #{id}" unless actor
      actor.target_dir = target_dir
      @actor_cache[id] = actor
    end
  end

  def update(actor)
    _actor = self.db.actors.find{|e| e == actor }
    if _actor
      _actor.target_dir = target_dir
      _actor.data_hash.update(actor.to_h)
    else
      actor.target_dir = target_dir
      self.db.actors << actor
    end
  end

end

module Shja::Actor; end

class Shja::Actor::Hc < Shja::ResourceBase
  # attr_reader :id
  # attr_reader :name
  # attr_reader :url
  # attr_reader :thumbnail
  attr_accessor :target_dir

  def initialize(data_hash)
    super(nil, data_hash)
  end

  def fetch_movies(agent)
    Shja::log.debug("Start fetching actor detail: #{self.id}")
    return _fetch_movie_list_from_actor_page(agent).map do |movie|
      movie['zip']     = _fetch_zip_url(agent, movie)
      movie['formats'] = _fetch_mp4_url(agent, movie)
      movie['id']      = _extract_movie_id(movie)
      movie
    end
  end

  def download(agent)
    Shja::log.debug("Start download actor: #{self.id}")
    self._download(agent, self.thumbnail, self.thumbnail_path)
  end

  def thumbnail_path
    File.join(self.dir_path, 'thumbnail.jpg')
  end

  def dir_path
    raise "target_dir is unset" unless self.target_dir
    return File.join(target_dir, dir_url)
  end

  def dir_url
    return self.id
  end

  def _fetch_movie_list_from_actor_page(agent)
    actor_page = agent._fetch_page(self.url)
    parser = Shja::Parser::HcActorPage.new(actor_page)
    return parser.parse_movies.map do |movie|
      m = Shja::Movie::Hc.new(movie)
      m.actor = self
      m
    end
  end

  def _fetch_zip_url(agent, movie)
    photoset_page = agent._fetch_page(movie.photoset_url)
    parser = Shja::Parser::HcZipPage.new(photoset_page)
    return parser.parse_zip_url
  end

  def _fetch_mp4_url(agent, movie)
    movie_page = agent._fetch_page(movie.url)
    parser = Shja::Parser::HcMoviePage.new(movie_page)
    return parser.parse
  end

  def _extract_movie_id(movie)
    File.basename(movie.photoset_url, '.*').tap do |id|
      Shja.log.debug("Movie id is: #{id}")
      # raise "Id is invalid, id: #{id}, url: #{movie.zip}" unless /\d+/ =~ id
    end
  end
end
