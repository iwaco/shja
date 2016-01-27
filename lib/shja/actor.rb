
class Shja::ActorManager < Shja::ManagerBase

  def find(id)
    self.db.actors.find{|e| e['id'] == id }.tap do |actor|
      raise "Actor not found: #{id}" unless actor
    end
  end

  def update(actor)
    _actor = self.db.actors.find{|e| e == actor }
    if _actor
      _actor.data_hash.update(actor.to_h)
    else
      self.db.actors << actor
    end
  end

end

class Shja::Actor < Shja::ResourceBase
  # attr_reader :id
  # attr_reader :name
  # attr_reader :url
  # attr_reader :thumbnail
end
