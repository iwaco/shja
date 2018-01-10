
class Shja::Client::Carib < Shja::D2PassClient

  def agent_class
    Shja::Agent::Carib
  end

  def movies_class
    Shja::MovieManager::Carib
  end

end
