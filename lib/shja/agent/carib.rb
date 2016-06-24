
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
    screenshot('before-login.jpg')
    fill_in(FORM_USER, with: username)
    fill_in(FORM_PASSWD, with: password)

    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
