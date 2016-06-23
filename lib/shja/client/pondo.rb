
class Shja::Client::Pondo < Shja::Client
  def initialize(
    username: username,
    password: password,
    answer: answer,
    target_dir: target_dir
  )
    @agent      = Shja::Agent::Pondo.new(username: username, password: password, answer: answer)
    @target_dir = target_dir
    @db         = Shja::Db::Pondo.get(target_dir)
    @context    = Hashie::Mash.new(
      agent: agent,
      db: db,
      target_dir: target_dir,
    )
    @movies     = Shja::MovieManager::Pondo.new(@context)
  end

  def refresh!(start_page: 0, last_page: 0)
    movies.download_index(start_page: start_page, last_page: last_page)
  end
end
