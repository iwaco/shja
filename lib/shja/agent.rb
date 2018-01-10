require 'memoist'
require 'mechanize'
require 'nokogiri'
require 'capybara'
require 'capybara/dsl'
require 'curb'
require 'webrick/cookie'
require 'uri'

class Shja::Agent
  attr_reader :agent
  attr_reader :username
  attr_reader :password
  attr_reader :context
  attr_accessor :is_login

  def initialize(username: nil, password: nil, context: nil)
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

  def initialize(username: nil, password: nil, context: nil)
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

class Shja::CapybaraAgent < Shja::CookieBasedAgent
  include Capybara::DSL

  def initialize(
    username: nil,
    password: nil,
    context: nil,
    cookies: '',
    selenium_url: 'http://chrome-headless:4444/wd/hub'
  )
    super(username: username, password: password, context: context)
    Capybara.run_server     = false
    Capybara.default_driver = :chrome
    Capybara.javascript_driver = :chrome
    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app,
        :browser => :remote,
        :desired_capabilities => :chrome,
        :url => selenium_url
      )
    end
    self.is_login = false
    init_agent
  end

  def init_agent
    @agent = page
  end

  def cookies_for(url)
    uri = URI.parse(url)
    return cookies_for_host(uri.host)
  end

  def cookies_for_host(host)
    cookies = self.agent.driver.browser.manage.all_cookies
    cookies.select{|c| valid_domain?(c, host)}
           .map{|c| "#{c[:name]}=#{c[:value]}"}
           .join('; ')
  end

  def valid_domain?(cookie, domain)
    ends_with?(("." + domain).downcase,
               normalize_domain(cookie[:domain]).downcase)
  end

  def normalize_domain(domain)
    domain = "." + domain unless domain[0,1] == "."
    domain
  end

  def ends_with?(str, suffix)
    str[-suffix.size..-1] == suffix
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
      open(File.join(logdir, "#{filename}.html"), 'w') do |io|
        io.write agent.body
      end
    end
  end

  def find_attribute(url, path, attribute)
    login unless self.is_login
    visit(url)
    screenshot('script.png')
    return find(path)[attribute]
  end

end

require 'shja/agent/pondo'
require 'shja/agent/carib'
