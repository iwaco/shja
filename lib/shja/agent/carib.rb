
class Shja::Agent::Carib < Shja::CapybaraAgent
  LOGIN_URL = 'http://www.caribbeancom.com/member/login.php?url=http://www.caribbeancom.com/listpages/all1.htm'

  attr_reader :answer

  def initialize(
      username: nil,
      password: nil,
      context: nil,
      answer: nil
    )
    super(username: username, password: password, context: context)
    @answer = answer
  end

  def login
    return if self.is_login

    visit(LOGIN_URL)
    screenshot('01.jpg')
    fill_in('FORM_USER', with: username)
    fill_in('FORM_PASSWD', with: password)
    find('input[name="login_btn"].loginButton').trigger('click')
    screenshot('02.jpg')
    # puts agent.html
    find('#sqaform input[name="a"]').send_keys(*answer.split(''))
    screenshot('03.jpg')
    find('#sqaform').trigger('submit')
    screenshot('04.jpg')

    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
