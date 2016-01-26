require 'fileutils'
require 'yaml'

class Shja::Db
  attr_reader :db_path
  attr_reader :data

  # TODO: test
  @@dbs = {}
  def self.get(target_dir)
    @@dbs[target_dir] ||= self.new(target_dir)
  end

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

  def save(actors)
    self.data['actors'] = actors
    _save
  end

  def _save
    open(self.db_path, 'w') do |io|
      io.write(self.data.to_yaml)
    end
  end

end
