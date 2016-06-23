require 'memoist'
require 'mechanize'

class Shja::Agent
  extend Memoist

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
      self.agent.download(url, io, [], LOGIN_URL)
    end
  end
end

require 'shja/agent/hc'
require 'shja/agent/pondo'
