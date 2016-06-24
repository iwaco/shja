
class Shja::Agent::Carib < Shja::CapybaraAgent
  LOGIN_URL = 'http://www.caribbeancom.com/member/login.php?url=http://www.caribbeancom.com/listpages/all1.htm'

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
    screenshot('login-01-before.jpg')
    fill_in('FORM_USER', with: username)
    fill_in('FORM_PASSWD', with: password)
    find('input[name="login_btn"].loginButton').trigger('click')
    screenshot('login-02-after.jpg')
    # puts agent.html
    find('#sqaform input[name="a"]').send_keys(*answer.split(''))
    screenshot('login-03-after.jpg')
    find('#sqaform').trigger('submit')
    screenshot('login-04-after.jpg')

    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
