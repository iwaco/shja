
class Shja::Agent::Carib < Shja::CapybaraAgent
  LOGIN_URL = 'http://www.caribbeancom.com/member/login.php?url=http://www.caribbeancom.com/listpages/all1.htm'

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
    fill_in('FORM_USER', with: username)
    fill_in('FORM_PASSWD', with: password)
    find('input[name="login_btn"].loginButton').click
    sleep(3)
    screenshot('02.png')
    # puts agent.html
    find('#sqaform input[name="a"]').send_keys(*answer.split(''))
    screenshot('03.png')
    # find('#sqaform').trigger('submit')
    execute_script("document.getElementById('sqaform').submit();")
    sleep(3)
    screenshot('04.png')

    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
