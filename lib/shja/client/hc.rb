
class Shja::Client::Hc
  attr_reader :agent
  attr_reader :actors
  attr_reader :movies
  attr_reader :target_dir

  def initialize(
    username: username,
    password: password,
    target_dir: target_dir
  )
    @agent      = Shja::Agent::Hc.new(username: username, password: password)
    @target_dir = target_dir
    @actors     = Shja::ActorManager.new(target_dir)
    @movies     = Shja::MovieManager.new(target_dir)
  end

  def refresh_actors(first_letter: 'A', last_letter: 'A')
    actors = agent.fetch_actors(
      first_letter: first_letter,
      last_letter: last_letter
    )
    actors.save(actors)
  end

end
