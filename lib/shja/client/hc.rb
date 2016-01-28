
class Shja::Client::Hc
  attr_reader :agent
  attr_reader :actors
  attr_reader :movies
  attr_reader :target_dir
  attr_reader :db

  def initialize(
    username: username,
    password: password,
    target_dir: target_dir
  )
    @agent      = Shja::Agent::Hc.new(username: username, password: password)
    @target_dir = target_dir
    @db         = Shja::Db.get(target_dir)
    @actors     = Shja::ActorManager.new(@db, target_dir)
    @movies     = Shja::MovieManager.new(@db, @actors)
  end

  def refresh_actors!(first_letter: 'A', last_letter: 'A')
    _actors = agent.fetch_actors(
      first_letter: first_letter,
      last_letter: last_letter
    )
    _actors.each do |actor|
      actors.update(actor)
    end
    db.save
  end

  def refresh_actor(actor_or_url)
    actor = agent.fetch_actor(actor_or_url)
    actors.update(actor)
    _movies = actor.fetch_movies(agent)
    _movies.each do |movie|
      movies.update(movie)
    end
    return actor
  end

  def refresh_actor!(actor_or_url)
    return refresh_actor(actor_or_url).tap do |actor|
      db.save
    end
  end

  def download_by_actor(actor_or_url, format=nil)
    begin
      actor = actors.find(actor_or_url)
    rescue
      actor = refresh_actor!(actor_or_url)
    end
    _movies = movies.find_by_actor(actor)

    actor.download(agent)
    _movies.each do |movie|
      movie.download(agent, format)
    end
  end

  def generate_html
    html = Shja::Html.new(movies: movies, target_dir: target_dir)
    html.generate_movies_js
  end

end
