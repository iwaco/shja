require 'json'

class Shja::MovieManager::Pondo < Shja::ManagerBase

  def download_index(start_page: 0, last_page: 0)
    return [].tap do |movie_ids|
      (start_page..last_page).each do |index|
        url = "http://www.1pondo.tv/dyn/ren/movie_lists/list_newest_#{index * 50}.json"
        movies = JSON.load(agent.fetch_page(url))
        movies['Rows'].each do |movie|
          movie = Shja::Movie::Pondo.new(context, movie)
          self.update(movie)
          movie_ids << movie[movie_id_key]
        end
      end
    end
  end

  def movie_id_key
    return 'MovieId'
  end

end

class Shja::Movie::Pondo < Shja::ResourceBase

end