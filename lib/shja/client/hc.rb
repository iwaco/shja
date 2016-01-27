
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
    @actors     = Shja::ActorManager.new(@db)
    @movies     = Shja::MovieManager.new(@db)
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
  end

  def refresh_actor!(actor_or_url)
    refresh_actor(actor_or_url)
    db.save
  end

end
