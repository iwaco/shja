
class Shja::Client::Pondo < Shja::D2PassClient

  def agent_class
    Shja::Agent::Pondo
  end

  def db_class
    Shja::Db::Pondo
  end

  def movies_class
    Shja::MovieManager::Pondo
  end

  def html_class
    Shja::Html::Pondo
  end

  def refresh_by_actor_id!(actor_id)
    movies.download_actor_index(actor_id)
  end

end
