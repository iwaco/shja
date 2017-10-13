
class Shja::Agent::Pondo < Shja::CapybaraAgent
  LOGIN_URL = "http://www.1pondo.tv/"

  attr_reader :answer

  def initialize(
      username: nil,
      password: nil,
      context: nil,
      answer: nil,
      selenium_url: 'http://chrome-headless:4444/wd/hub'
    )
    super(username: username, password: password, context: context, selenium_url: selenium_url)
    @answer = answer
  end

  def login
    return if self.is_login

    visit(LOGIN_URL)
    sleep(3)
    screenshot('01.png')
    # find('.age-verification .enter button.color-main').click
    execute_script("document.querySelectorAll('.age-verification .enter button.color-main')[0].click();")
    sleep 3
    screenshot('02.png')
    # find('modal-login .login-btn button').click
    execute_script("document.querySelectorAll('modal-login .login-btn button')[0].click();")
    sleep 3
    screenshot('03.png')
    fill_in('login', with: username)
    fill_in('password', with: password)
    # find('.login-box form button.login-button').click
    execute_script("document.querySelectorAll('.login-box form button.login-button')[0].click();")
    sleep 3
    screenshot('04.png')

    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
