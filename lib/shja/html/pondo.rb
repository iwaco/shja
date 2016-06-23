require 'pathname'

class Shja::Html::Pondo < Shja::Html

  def relative_path(movie, to)
    path_from = Pathname(File.dirname(movie.top_dir_url))
    path_to = Pathname(to)
    return path_to.relative_path_from(path_from).to_s
  end

  def movies_js_list
    json = []
    movies.all do |movie|
      generate_detail_js(movie)
      js = {}
      js['id'] = movie.movie_id
      js['dir'] = movie.top_dir_url
      js['jpg'] = relative_path(movie, movie.thumbnail_url)
      js['detail'] = relative_path(movie, movie.photoset_dir_url)
      js['title'] = movie.title
      js['url'] = "http://www.1pondo.tv/moviepages/#{movie.movie_id}"
      js['date'] = movie.release
      js['actors'] = [*movie.actor.split(',')]
      js['tags'] = [*movie.uc_name]
      js['formats'] = movie.detail.formats
                           .select {|k, _| movie.exists?(k)}
                           .map{|k, _| [k, relative_path(movie, movie.movie_url(k))]}
                           .to_h
      json << js
    end
    json
  end

end
