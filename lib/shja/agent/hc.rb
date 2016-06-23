
class Shja::Agent::Hc < Shja::Agent

  BASE_URL = "http://ex.shemalejapanhardcore.com"
  LOGIN_URL = "#{BASE_URL}/members/"
  CAPTCHA_URL = "http://ex.shemalejapanhardcore.com/cptcha.jpg"

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

  def referrer_url
    LOGIN_URL
  end

  def fetch_actors(first_letter: 'A', last_letter: 'A')
    return [].tap do |actors|
      (first_letter..last_letter).each do |letter|
        actors.push( *fetch_index_page(letter: letter) )
      end
    end
  end

  def fetch_actor(actor_or_url)
    url = actor_or_url
    if actor_or_url.kind_of?(Shja::Actor::Hc)
      url = actor_or_url.url
    end
    unless /^http/ =~ url
      url = "#{BASE_URL}/members/models/#{url}.html"
    end
    actor_page = _fetch_page(url)
    parser = Shja::Parser::HcActorPage.new(actor_page)
    return Shja::Actor::Hc.new(parser.parse_actor).tap do |actor|
      actor['url'] = url
      actor['id']  = File.basename(url, '.html')
    end
  end

  def fetch_index_page(letter: 'A')
    Shja::log.debug("Start fetching index: #{letter}")
    page = _fetch_index_page(letter: letter)
    parser = Shja::Parser::HcIndexPage.new(page)
    return [].tap do |actors|
      pagination = parser.parse_pagination
      if pagination.size > 0
        pagination.each do |url|
          page = _fetch_page(url)
          parser = Shja::Parser::HcIndexPage.new(page)
          actors.push( *parser.parse_actors.map { |e| Shja::Actor::Hc.new(e) } )
        end
      else
        actors.push( *parser.parse_actors.map { |e| Shja::Actor::Hc.new(e) } )
      end
    end
  end

  def _fetch_page(url)
    return fetch_page(url)
  end

  def _fetch_index_page(letter: 'A', index: 0)
    url = "http://ex.shemalejapanhardcore.com/members/categories/models/#{index+1}/name/#{letter}/"
    _fetch_page(url)
  end

end
