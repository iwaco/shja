
class Shja::Html
  attr_reader :movies
  attr_reader :target_dir

  def initialize(movies: movies, target_dir: target_dir)
    @movies = movies
    @target_dir = target_dir
  end

  def generate_movies_js
    open(File.join(target_dir, "movies.js"), 'w') do |io|
      io.write('var movies = ' + JSON.generate(_movies_js_list) + ';')
    end
  end

  def generate_detail_js(movie)
    return unless movie.has_pictures?
    metadata = movie.pictures_metadata
    open(File.join(movie.photoset_dir_path, 'index.js'), 'w') do |io|
      io.write("calbackImageFilename(" + JSON.pretty_generate(metadata) + ");")
    end
  end

  def _movies_js_list
    json = []
    movies.all do |movie|
      generate_detail_js(movie)
      js = {}
      js['id'] = movie.id
      js['dir'] = movie.dir_url
      js['jpg'] = 'thumbnail.jpg'
      js['detail'] = 'photoset'
      js['title'] = movie.title
      js['url'] = movie.url
      js['date'] = movie.date
      js['actors'] = [movie.actor.name]
      js['tags'] = []
      js['formats'] = movie.formats
                           .select {|k, _| movie.movie_exist?(k)}
                           .map{|k, _| [k, "#{k}.mp4"]}
                           .to_h
      json << js
    end
    json
  end

end
