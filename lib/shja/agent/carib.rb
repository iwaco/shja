
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
    # agent.execute_script("set_username_changed();set_pwd_changed();submit_clicked()")
    # submit = find('input[name="login_btn"].loginButton')
    # p submit.click
    # form = find('#form1')
    # form.trigger('submit')
    # submit.trigger('click')
    # find_button('login_btn').trigger('click')
    find('input[name="login_btn"].loginButton').trigger('click')
    # sleep 3
    # find('#form1').trigger('submit')
    # puts agent.evaluate_script('document.getElementById("form1").submit()')
    # puts agent.evaluate_script('document.getElementById("form1").style.display="none"')
    sleep 3
    screenshot('login-02-after.jpg')
    # puts agent.evaluate_script('document.getElementById("form1").id')
    # sleep 3
    # screenshot('login-03-after.jpg')
    self.is_login = true
  end

  def referrer_url
    LOGIN_URL
  end

end
