
class Shja::Server::Carib < Shja::Server

  get '/api/movies/:year' do |year|
    unless /\d{4}/ =~ year
      return 404
    end
    movies = db.find_movies("movie/#{year}").map do |movie|
      Shja::Server::Carib::Movie.new(movie).to_h
    end
    return json movies
  end

end

class Shja::Server::Carib::Movie
  attr_reader :raw

  def initialize(raw)
    @raw = raw
  end

  def to_h
    {}.tap do |rtn|
      rtn['date'] = raw.date
      rtn['title'] = raw.title
    end
  end

end
