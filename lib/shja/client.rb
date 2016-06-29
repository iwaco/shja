require 'hashie'

class Shja::Client
  attr_reader :agent
  attr_reader :movies
  attr_reader :target_dir
  attr_reader :db


end

class Shja::D2PassClient < Shja::Client
  attr_reader :result
  attr_reader :fault_result

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

    @result       = []
    @fault_result = []
  end

  def refresh!(start_page: 0, last_page: 0)
    movies.download_index(start_page: start_page, last_page: last_page)
  end

  def _download_movie(movie, format)
    reason = ''
    begin
      if movie.download(format)
        self.result << movie
        return true
      end
    rescue => ex
      reason = ex.message
      Shja.log.error(ex.message)
      Shja.log.error(ex.backtrace.join("\n"))
    end
    self.fault_result << [movie, reason]
    return false
  end

  def random_download(count=10, format=nil, try_count: 20, try_ratio: 2)
    try_count = count * try_ratio if (try_count < try_ratio * count)
    _movies = []
    movies.all do |movie|
      _movies << movie unless movie.exists?(format)
    end
    _movies = _movies.shuffle
    _movies.each do |movie|
      if _download_movie(movie, format)
        count -= 1
      else
        try_count -= 1
      end
      return if count < 1
      return if try_count < 1
    end
  end

  def download_by_latest(count=10, format=nil, try_count: 20, try_ratio: 2)
    try_count = count * try_ratio if (try_count < try_ratio * count)
    movies.all do |movie|
      unless movie.exists?(format)
        if _download_movie(movie, format)
          count -= 1
        else
          try_count -=20
        end
        return if count < 1
        return if try_count < 1
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
      unless movie.exists?(format)
        _download_movie(movie, format)
      end
    end
  end

  def print_result
    puts "Downloaded: Total #{result.size} / #{result.size = fault_result.size}"
    result.each do |movie|
      puts "    ----> SUCEEDED: #{movie.title}, #{movie.dir_url}"
    end
    fault_result.each do |movie, reason|
      puts "    ----> FAILED: #{movie.title}, #{movie.dir_url}, #{reason}"
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
