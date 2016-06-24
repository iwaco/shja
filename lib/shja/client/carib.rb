
class Shja::Client::Carib < Shja::D2PassClient

  def agent_class
    Shja::Agent::Carib
  end

  def db_class
    Shja::Db::Carib
  end

  def movies_class
    Shja::MovieManager::Carib
  end

  def html_class
    Shja::Html::Carib
  end

end
