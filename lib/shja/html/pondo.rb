require 'pathname'

class Shja::Html::Pondo < Shja::Html

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
      js['id'] = movie.movie_id
      js['dir'] = movie.top_dir_url
      js['jpg'] = relative_path(movie, movie.thumbnail_url)
      js['detail'] = relative_path(movie, movie.photoset_dir_url)
      js['title'] = movie.title
      js['url'] = movie.page_remote_url
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
