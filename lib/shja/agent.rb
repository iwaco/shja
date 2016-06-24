require 'memoist'
require 'mechanize'
require 'nokogiri'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'curb'

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
Capybara.current_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    js: true,
    js_errors: false,
    timeout: 5000,
    debug: true,
    window_size: [1980, 1080],
    phantomjs_options: ['--ignore-ssl-errors=true']
  })
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
    @agent = page
    # @agent = Capybara::Session.new(:poltergeist)
    @agent.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
  end

  def login
    raise "Unimplemented"
  end

  def referrer_url
    raise "Unimplemented"
  end

  def create_curl_agent(url)
    login unless self.is_login
    curl_agent = Curl::Easy.new(url)
    curl_agent.follow_location = true
    curl_agent.max_redirects = 5
    curl_agent.headers = curl_agent.headers.merge(agent.driver.headers)
    curl_agent.headers["Cookie"] = agent.driver.cookies.each_with_object([]) { |(key, value), array|
      array.push("#{key}=#{value.value}")
    }.join('; ')
    return curl_agent
  end

  def _get_url(url)
    curl = create_curl_agent(url)
    curl.get
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

  def download(url, path)
    login unless self.is_login
    Shja.log.debug("_download: #{url}")

    open(path, 'wb') do |io|
      body = _get_url(url)
      # puts body
      io.write(body)
    end
  rescue => ex
    Shja.log.error(ex.message)
    Shja.log.error(ex.backtrace.join("\n"))
  end
end

require 'shja/agent/hc'
require 'shja/agent/pondo'
require 'shja/agent/carib'
