
class Shja::Html::Hc < Shja::Html

  def movies_js_list
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
