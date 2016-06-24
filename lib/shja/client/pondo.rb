
class Shja::Client::Pondo < Shja::Client
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
    @agent      = Shja::Agent::Pondo.new(
      username: username,
      password: password,
      answer: answer,
      context: @context
    )
    @db         = Shja::Db::Pondo.get(@context)
    @movies     = Shja::MovieManager::Pondo.new(@context)
  end

  def refresh!(start_page: 0, last_page: 0)
    movies.download_index(start_page: start_page, last_page: last_page)
  end

  def random_download(count=10, format=nil)
    _movies = []
    movies.all do |movie|
      _movies << movie unless movie.exists?(format)
    end
    _movies = _movies.sample(count)
    _movies.each do |movie|
      movie.download(format)
    end
  end

  def download_by_id(id, format=nil)
    movie = movies.find(id)
    movie.download(format)
  end

  def download_by_actor_id(id, format=nil)
    _movies = []
    movies.all do |movie|
      if movie.actor_id.include?(id)
        _movies << movie
      end
    end
    _movies.each do |movie|
      movie.download(format)
    end
  end

  def generate_html
    html = Shja::Html::Pondo.new(movies: movies, target_dir: target_dir)
    html.generate_movies_js
  end

end
