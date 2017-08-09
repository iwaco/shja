
class Shja::Agent::Pondo < Shja::CapybaraAgent
  LOGIN_URL = "http://www.1pondo.tv/"

  attr_reader :answer

  def initialize(
      username: nil,
      password: nil,
      context: nil,
      answer: nil,
      selenium_url: 'http://chrome-headless:4444/wd/hub',
    )
    super(username: username, password: password, context: context, selenium_url: selenium_url)
    @answer = answer
  end

  def login
    return if self.is_login

    visit(LOGIN_URL)
    screenshot('01.jpg')
    find('.age-verification .enter button.color-main').trigger('click')
    sleep 2
    screenshot('02.jpg')
    find('modal-login .login-btn button').trigger('click')
    sleep 1
    screenshot('03.jpg')
    fill_in('login', with: username)
    fill_in('password', with: password)
    find('.login-box form button.login-button').trigger('click')
    sleep 2
    screenshot('04.jpg')

    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
