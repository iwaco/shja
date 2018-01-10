
class Shja::Client::Pondo < Shja::D2PassClient

  def agent_class
    Shja::Agent::Pondo
  end

  def movies_class
    Shja::MovieManager::Pondo
  end

end
