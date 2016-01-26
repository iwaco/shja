
class Shja::Client::Hc
  attr_reader :agent
  attr_reader :db
  attr_reader :target_dir

  def initialize(
    username: username,
    password: password,
    target_dir: target_dir
  )
    @agent      = Shja::Agent::Hc.new(username: username, password: password)
    @db         = Shja::Db.new(target_dir)
    @target_dir = target_dir
  end

  def refresh_actors(first_letter: 'A', last_letter: 'A')
    actors = agent.fetch_actors(
      first_letter: first_letter,
      last_letter: last_letter
    )
    db.save(actors)
  end

  def download(actor_id, format='720p')
    actor = db.find_actor(actor_id)
    raise "Actor not found: #{actor_id}" unless actor
  end
end
