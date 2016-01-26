require 'memoist'

class Shja::Agent::Hc
  extend Memoist

  BASE_URL = "http://ex.shemalejapanhardcore.com"
  LOGIN_URL = "#{BASE_URL}/members/"
  CAPTCHA_URL = "http://ex.shemalejapanhardcore.com/cptcha.jpg"
  attr_reader :agent
  attr_reader :username
  attr_reader :password
  attr_accessor :is_login

  def initialize(username: username, password: password)
    @username = username
    @password = password

    @agent = Mechanize.new
    @agent.user_agent = 'Mac Safari'

    self.is_login = false
  end

  def login
    return if self.is_login
    page = agent.get(LOGIN_URL)
    agent.get("#{BASE_URL}/cptcha.jpg", referer: LOGIN_URL)
    agent.get("#{BASE_URL}/tour/custom_assets/images/logo.png", referer: LOGIN_URL)

    Shja::log.debug("login with, username: #{username}, password: #{password}")
    form = page.form_with(action: '/auth.form')
    form.field_with(name: 'uid').value = self.username
    form.field_with(name: 'pwd').value = self.password
    button = form.button_with(:value => "Enter")
    page = agent.submit(form, button)
    if page.search('form[action="/auth.form"]').size != 0
      form = page.form_with(action: '/auth.form')
      form.field_with(name: 'uid').value = self.username
      form.field_with(name: 'pwd').value = self.password
      button = form.button_with(:value => "Enter")
    end

    self.is_login = true
  end

  def fetch_actors(first_letter: 'A', last_letter: 'A')
    return [].tap do |actors|
      (first_letter..last_letter).each do |letter|
        actors.push( *fetch_index_page(letter: letter) )
      end
    end
  end

  def fetch_index_page(letter: 'A')
    page = _fetch_index_page(letter: letter)
    parser = Shja::Parser::HcIndexPage.new(page)
    return [].tap do |actors|
      pagination = parser.parse_pagination
      if pagination.size > 0
        pagination.each do |url|
          page = _fetch_page(url)
          parser = Shja::Parser::HcIndexPage.new(page)
          actors.push( *parser.parse_actors )
        end
      else
        actors.push( *parser.parse_actors )
      end
    end
  end

  def _fetch_page(url)
    login unless self.is_login
    Shja.log.debug("_fetch_page: #{url}")

    page = agent.get(url)
    page.content
  end
  memoize :_fetch_page

  def _fetch_index_page(letter: 'A', index: 0)
    url = "http://ex.shemalejapanhardcore.com/members/categories/models/#{index+1}/name/#{letter}/"
    _fetch_page(url)
  end

end
