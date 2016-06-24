
class Shja::Html
  attr_reader :movies
  attr_reader :target_dir

  def initialize(movies: movies, target_dir: target_dir)
    @movies = movies
    @target_dir = target_dir
  end

  def generate_movies_js
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

  def movies_js_list
    raise 'Unimplemented'
  end

end

require 'shja/html/hc'
require 'shja/html/pondo'
require 'shja/html/carib'
