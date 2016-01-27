
class Shja::MovieManager < Shja::ManagerBase

end

class Shja::Movie < Shja::ResourceBase
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
