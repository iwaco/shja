
class Shja::Agent::Pondo < Shja::Agent
  LOGIN_URL = "http://www.1pondo.tv/"

  attr_reader :answer

  def initialize(
      username: username,
      password: password,
      answer: answer
    )
    super(username: username, password: password)
    @answer = answer
  end

  def login
    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
