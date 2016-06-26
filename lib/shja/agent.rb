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
  extend Memoist

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

    @agent = Mechanize.new
    @agent.user_agent = 'Mac Safari'

    self.is_login = false
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

class Shja::CapybaraAgent
  include Capybara::DSL
  extend Memoist

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
    @is_login = false

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

  def login
    raise "Unimplemented"
  end

  def referrer_url
    raise "Unimplemented"
  end

  def _cookies
    agent.driver.browser.get_cookies.map { |c| WEBrick::Cookie.parse_set_cookie(c) }
  end

  def _get_cookies(url)
    uri = URI.parse(url)
    return _cookies.select {|c| valid_domain?(c, uri.host)}.map {|c| "#{c.name}=#{c.value}" }.join('; ')
  end

  def valid_domain?(cookie, domain)
    ends_with?(("." + domain).downcase,
               normalize_domain(cookie.domain).downcase)
  end

  def normalize_domain(domain)
    domain = "." + domain unless domain[0,1] == "."
    domain
  end

  def ends_with?(str, suffix)
    str[-suffix.size..-1] == suffix
  end

  def create_curl_agent(url)
    login unless self.is_login
    curl_agent = Curl::Easy.new(url)
    curl_agent.follow_location = true
    curl_agent.max_redirects = 5
    cookies = _get_cookies(url)
    Shja.log.debug("Cookies: #{cookies}")
    curl_agent.headers["Cookie"] = _get_cookies(url)
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

  def logdir
    File.join(context.target_dir, 'logs')
  end

  def screenshot(filename)
    if Shja.log.debug?
      FileUtils.mkdir_p(logdir) unless File.directory?(logdir)
      agent.save_screenshot(File.join(logdir, filename), full: true)
    end
  end

  def fetch_page(url)
    login unless self.is_login
    Shja.log.debug("fetch_page: #{url}")

    return _get_url(url)
  end
  memoize :fetch_page

  def download(url, path, unexpected_types=[])
    login unless self.is_login
    Shja.log.debug("_download: #{url}")

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

require 'shja/agent/hc'
require 'shja/agent/pondo'
require 'shja/agent/carib'
