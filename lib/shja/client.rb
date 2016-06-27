require 'hashie'

class Shja::Client
  attr_reader :agent
  attr_reader :movies
  attr_reader :target_dir
  attr_reader :db


end

class Shja::D2PassClient < Shja::Client
  attr_reader :result

  def agent_class
    raise "Unimplemented"
  end

  def db_class
    raise "Unimplemented"
  end

  def movies_class
    raise "Unimplemented"
  end

  def html_class
    raise "Unimplemented"
  end

  def initialize(
    username: username,
    password: password,
    answer: answer,
    target_dir: target_dir
  )
    @target_dir = target_dir
    @context    = Hashie::Mash.new(
      target_dir: target_dir,
    )
    @agent      = agent_class.new(
      username: username,
      password: password,
      answer: answer,
      context: @context
    )
    @db         = db_class.get(@context)
    @movies     = movies_class.new(@context)

    @result     = []
  end

  def refresh!(start_page: 0, last_page: 0)
    movies.download_index(start_page: start_page, last_page: last_page)
  end

  def _download_movie(movie, format)
    if movie.download(format)
      self.result << movie
      return true
    end
    return false
  end

  def random_download(count=10, format=nil)
    _movies = []
    movies.all do |movie|
      _movies << movie unless movie.exists?(format)
    end
    _movies = _movies.sample(count)
    _movies.each do |movie|
      begin
        _download_movie(movie, format)
      rescue => ex
        Shja.log.error(ex.message)
        Shja.log.error(ex.backtrace.join("\n"))
      end
    end
  end

  def download_by_latest(count=10, format=nil, try_ratio=2)
    try_count = count * try_ratio
    movies.all do |movie|
      begin
        if _download_movie(movie, format)
          Shja.log.debug("Downloaded...")
          count -= 1
        end
        if count == 0
          return
        end
      rescue => ex
        Shja.log.error(ex.message)
        Shja.log.error(ex.backtrace.join("\n"))
        try_count -= 1
        if try_count == 0
          Shja.log.debug("Max try_count exeeded")
          return
        end
      end
    end
  end

  def download_by_id(id, format=nil)
    movie = movies.find(id)
    _download_movie(movie, format)
  end

  def download_by_actor(name, format=nil)
    _movies = []
    movies.all do |movie|
      if movie.actor?(name)
        _movies << movie
      end
    end
    _movies.each do |movie|
      _download_movie(movie, format)
    end
  end

  def print_result
    puts "Downloaded: Total #{result.size}"
    result.each do |movie|
      puts "    ----> #{movie.title}, #{movie.dir_url}"
    end
  end

  def generate_html
    html = html_class.new(movies: movies, target_dir: target_dir)
    html.generate_movies_js
    html.generate_recent_js
  end
end

require 'shja/client/hc'
require 'shja/client/pondo'
require 'shja/client/carib'
