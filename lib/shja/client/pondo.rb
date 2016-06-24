
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
    raise Shja::Html::Pondo
  end

end
