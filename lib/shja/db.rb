require 'json'
require 'hashie'
require 'etcdv3'

class Shja::Db
  attr_reader :connection

  def initialize(
    endpoints: 'http://127.0.0.1:2379'
  )
    @connection = ::Etcdv3.new(endpoints: endpoints)
  end

  def save_movie(movie)
    movie = movie_class.new(movie) unless movie.kind_of?(movie_class)
    connection.put(to_key(movie), movie.to_json.force_encoding('ASCII-8BIT'))
  end

  def get_movie(key)
    movie = connection.get(to_key(key)).kvs[0]&.value
    to_movie(movie)
  end

  def find_movies(prefix_key)
    rtn = []
    # prefix_key = "movie/#{prefix_key}" # TODO 'movies' should be another place
    key = to_key(prefix_key)
    connection.get(key, range_end: key.succ).kvs.each do |movie|
      movie = to_movie(movie.value)
      if block_given?
        yield movie
      else
        rtn << movie
      end
    end
    rtn
  end

  def to_key(obj)
    if obj.respond_to?(:key)
      obj = obj.key
    end
    "#{prefix}/#{obj}"
  end

  def to_movie(str)
    if str
      movie = JSON.load(str.dup.force_encoding('UTF-8'))
      movie = movie_class.new(movie)
    else
      nil
    end
  end

  def prefix
    raise "Unimplemented"
  end

  def movie_class
    raise "Unimplemented"
  end

  def destroy_db!
    connection.del(prefix, range_end: prefix.succ)
  end
end

require 'shja/db/carib'
