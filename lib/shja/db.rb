require 'fileutils'
require 'yaml'

class Shja::Db
  attr_reader :db_path
  attr_reader :data

  def initialize(target_dir)
    unless File.directory?(target_dir)
      FileUtils.mkdir_p(target_dir)
    end
    @db_path = File.join(target_dir, 'db.yml')

    self.load
  end

  def load
    @data = {
      'actors' => []
    }
    if File.file?(self.db_path)
      open(self.db_path) do |io|
        @data = YAML.load(io.read)
      end
    end
  end

  def find_actor_by_name(name)
    self.data['actors'].find {|a| a['name'] == name }
  end

  def find_actor(id)
    self.data['actors'].find {|a| a['id'] == id }
  end

  def save(actors)
    actors.each do |actor|
      if org = find_actor(actor['id'])
        org.update(actor)
      else
        self.data['actors'] << actor
      end
    end
    self.data['actors'].sort!{|a, b| a['id'] <=> b['id']}
    _save
  end

  def _save
    open(self.db_path, 'w') do |io|
      io.write(self.data.to_yaml)
    end
  end

end
