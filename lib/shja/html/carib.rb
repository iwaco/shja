require 'pathname'

class Shja::Html::Carib < Shja::Html

  def relative_path(movie, to)
    path_from = Pathname(movie.top_dir_url)
    path_to = Pathname(to)
    path = path_to.relative_path_from(path_from).to_s
    return path
  end

  def movies_js_list
    json = []
    movies.all do |movie|
      generate_detail_js(movie)
      js = {}
      js['id'] = movie.id
      js['dir'] = movie.top_dir_url(false)
      js['jpg'] = relative_path(movie, movie.thumbnail_url(false))
      js['detail'] = relative_path(movie, movie.photoset_dir_url(false))
      js['title'] = movie.title
      js['url'] = movie.url
      js['date'] = movie.date
      js['actors'] = movie.actors
      js['tags'] = movie.tags
      js['formats'] = movie.formats.keys
                           .select {|k, _| movie.exists?(k)}
                           .map{|k, _| [k, relative_path(movie, movie.movie_url(k, false))]}
                           .to_h
      json << js
    end
    json
  end

end
