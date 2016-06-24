
class Shja::MovieManager::Carib < Shja::MovieManager

  def download_index(start_page: 0, last_page: 0)
    agent.login
    return []
  end

  def movie_id_key
    return 'MovieID'
  end

  def find(id)
    Shja::Movie::Carib.new(context, _find(id))
  end

  def all
    _all do |movie|
      yield Shja::Movie::Carib.new(context, movie)
    end
  end

end

class Shja::Movie::Carib < Shja::Movie
end
