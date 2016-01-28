
class Shja::ActorManager < Shja::ManagerBase
  attr_reader :target_dir

  def initialize(db, target_dir)
    super(db)
    @target_dir = target_dir
  end

  def find(id)
    self.db.actors.find{|e| e['id'] == id }.tap do |actor|
      raise "Actor not found: #{id}" unless actor
      actor.target_dir = target_dir
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

class Shja::Actor < Shja::ResourceBase
  # attr_reader :id
  # attr_reader :name
  # attr_reader :url
  # attr_reader :thumbnail
  attr_accessor :target_dir

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
    return File.join(target_dir, self.id)
  end

  def _fetch_movie_list_from_actor_page(agent)
    actor_page = agent._fetch_page(self.url)
    parser = Shja::Parser::HcActorPage.new(actor_page)
    return parser.parse_movies.map do |movie|
      m = Shja::Movie.new(movie)
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
