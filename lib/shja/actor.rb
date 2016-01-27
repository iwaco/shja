
class Shja::ActorManager < Shja::ManagerBase

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

end
