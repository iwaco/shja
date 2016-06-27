require 'memoist'
require 'mechanize'
require 'nokogiri'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'headless'
require 'curb'
require 'webrick/cookie'
require 'uri'

class Shja::Agent
  attr_reader :agent
  attr_reader :username
  attr_reader :password
  attr_reader :context
  attr_accessor :is_login

  def initialize(username: username, password: password, context: context)
    @username = username
    @password = password
    @context = context
    @context.agent = self

    self.is_login = false
  end

  def login
    raise "Unimplemented"
  end

  def referrer_url
    raise "Unimplemented"
  end

  def fetch_page(url)
    raise "Unimplemented"
  end

  def download(url, path)
    raise "Unimplemented"
  end
end

class Shja::MechanizeAgent < Shja::Agent
  extend Memoist

  def initialize(username: username, password: password, context: context)
    super
    @agent = Mechanize.new
    @agent.user_agent = 'Mac Safari'
  end

  def login
    raise "Unimplemented"
  end

  def referrer_url
    raise "Unimplemented"
  end

  def fetch_page(url)
    login unless self.is_login
    Shja.log.debug("fetch_page: #{url}")

    page = agent.get(url)
    page.content
  end
  memoize :fetch_page

  def download(url, path)
    login unless self.is_login
    Shja.log.debug("_download: #{url}")

    open(path, 'wb') do |io|
      self.agent.download(url, io, [], referrer_url)
    end
  end
end

class Shja::CookieBasedAgent < Shja::Agent
  attr_reader :cookies
  extend Memoist

  def initialize(username: nil, password: nil, context: nil, cookies: '')
    super(username: username, password: password, context: context)
    @cookies = cookies
    self.is_login = true
  end

  def cookies_for(url)
    self.cookies
  end

  def create_curl_agent(url)
    login unless self.is_login
    curl_agent = Curl::Easy.new(url)
    curl_agent.follow_location = true
    curl_agent.max_redirects = 5
    cookies = self.cookies_for(url)
    Shja.log.debug("Cookies: #{cookies}")
    curl_agent.headers["Cookie"] = cookies
    return curl_agent
  end

  def _get_url(url, unexpected_types=[])
    curl = create_curl_agent(url)
    curl.get
    if curl.response_code >= 300
      raise "Unexpected response code: #{curl.response_code}, #{url}"
    end
    unexpected_types.each do |type|
      if curl.content_type.include?(type)
        raise "Unexpected content_type: #{curl.content_type}, #{url}"
      end
    end
    return curl.body_str
  end

  def fetch_page(url)
    login unless self.is_login
    Shja.log.debug("Fetch page: #{url}")

    return _get_url(url)
  end
  memoize :fetch_page

  def download(url, path, unexpected_types=[])
    login unless self.is_login
    Shja.log.debug("Download: #{url}")

    open(path, 'wb') do |io|
      body = _get_url(url, unexpected_types)
      # puts body
      io.write(body)
    end
    return true
  rescue => ex
    Shja.log.error("Download failed: #{url}")
    FileUtils.rm(path) if File.file?(path)
    raise ex
  end
end

# Monkey patch for capybara-webkit
require 'capybara/webkit/cookie_jar'
class Capybara::Webkit::CookieJar

  def cookies_for(url)
    uri = URI.parse(url)
    return cookies.select {|c| valid_domain?(c, uri.host)}.map {|c| "#{c.name}=#{c.value}" }.join('; ')
  end
end

Capybara.run_server     = false
Capybara.default_driver = :webkit
Capybara::Webkit.configure do |config|
  config.allow_url("d2pass.com")
  config.allow_url("caribbeancom.com")
  config.allow_url("1pondo.tv")
  config.allow_url("google-analytics.com")
  config.allow_url("googleapis.com")
  config.allow_url("amazonaws.com")
  config.allow_url("doubleclick.net")
  config.allow_url("crazyegg.com")
end

class Shja::CapybaraAgent < Shja::CookieBasedAgent
  include Capybara::DSL

  def initialize(username: nil, password: nil, context: nil, cookies: '')
    super
    self.is_login = false
    init_agent
  end

  def init_agent
    h = Headless.new()
    h.start
    @agent = page
    ObjectSpace.define_finalizer(@agent) do
      h.destroy
    end
  end

  def cookies_for(url)
    self.agent.driver.cookies.cookies_for(url)
  end

  def login
    raise "Unimplemented"
  end

  def referrer_url
    raise "Unimplemented"
  end

  def logdir
    File.join(context.target_dir, 'logs')
  end

  def screenshot(filename)
    if Shja.log.debug?
      FileUtils.mkdir_p(logdir) unless File.directory?(logdir)
      agent.save_screenshot(File.join(logdir, filename), full: true)
    end
  end

end

require 'shja/agent/hc'
require 'shja/agent/pondo'
require 'shja/agent/carib'
