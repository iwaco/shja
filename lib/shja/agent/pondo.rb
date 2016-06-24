
class Shja::Agent::Pondo < Shja::CapybaraAgent
  LOGIN_URL = "http://www.1pondo.tv/"

  attr_reader :answer

  def initialize(
      username: username,
      password: password,
      context: context,
      answer: answer
    )
    super(username: username, password: password, context: context)
    @answer = answer
  end

  def login
    return if self.is_login

    visit(LOGIN_URL)
    screenshot('01.jpg')

    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
