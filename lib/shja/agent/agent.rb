
class Shja::Agent::Pondo < Shja::Agent
  LOGIN_URL = "http://www.1pondo.tv/"

  def login
    self.is_login = true
  end

end
