
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

  def logdir
    File.join(context.target_dir, 'logs')
  end

  def login
    agent.visit(LOGIN_URL)
    screenshot('before-login.jpg')

    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
