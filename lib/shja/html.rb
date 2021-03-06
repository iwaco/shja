
class Shja::Html
  attr_reader :movies
  attr_reader :target_dir

  def initialize(movies: nil, target_dir: nil)
    @movies = movies
    @target_dir = target_dir
  end

  def generate_movies_js
    Shja.log.debug('generate_movies_js')
    open(File.join(target_dir, "movies.js"), 'w') do |io|
      io.write('var movies = ' + JSON.generate(movies_js_list) + ';')
    end
  end

  def generate_detail_js(movie)
    return unless movie.has_pictures?
    metadata = movie.pictures_metadata
    open(File.join(movie.photoset_dir_path, 'index.js'), 'w') do |io|
      io.write("calbackImageFilename(" + JSON.pretty_generate(metadata) + ");")
    end
  end

  def generate_recent_js
    Shja.log.debug('generate_recent_js')
    open(File.join(target_dir, "recent_movies.js"), 'w') do |io|
      io.write('var recent_movies = ' + JSON.generate(recent_movies_js_list) + ';')
    end
  end

  def movies_js_list
    raise 'Unimplemented'
  end

  def recent_movies_js_list
    recent_movies = []
    movies.all do |movie|
      if movie.updated_date
        if recent_movies.size > 50
          last_movie = recent_movies.pop
          if movie.updated_date > last_movie.updated_date
            recent_movies << movie
            recent_movies.sort! { |a, b| b.updated_date <=> a.updated_date }
          else
            recent_movies << last_movie
          end
        else
          recent_movies << movie
        end
      end
    end
    return recent_movies.map { |movie| movie.id }
  end

end

require 'shja/html/hc'
require 'shja/html/pondo'
require 'shja/html/carib'
