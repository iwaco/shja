
class Shja::MovieManager < Shja::ManagerBase

  def find(id)
    self.db.movies.find{|e| e['id'] == id }.tap do |movie|
      raise "Movie not found: #{id}" unless movie
    end
  end

  def update(movie)
    _movie = self.db.movies.find{|e| e == movie }
    if _movie
      _movie.data_hash.update(movie.to_h)
    else
      self.db.movies << movie
    end
  end

end

class Shja::Movie < Shja::ResourceBase
  # attr_reader :id
  # attr_reader :actor_id
  # attr_reader :title
  # attr_reader :url
  # attr_reader :photoset_url
  # attr_reader :thumbnail
  # attr_reader :date
  # attr_reader :zip
  # attr_reader :formats

  def actor=(actor)
    self['actor_id'] = actor.id
  end
end
