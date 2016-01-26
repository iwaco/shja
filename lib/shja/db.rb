require 'fileutils'
require 'yaml'

class Shja::Db
  attr_reader :db_path
  attr_reader :actors

  def initialize(target_dir)
    unless File.directory?(target_dir)
      FileUtils.mkdir_p(target_dir)
    end
    @db_path = File.join(target_dir, 'db.yml')

    self.load
  end

  def load
    @actors = []
    if File.file?(self.db_path)
      open(self.db_path) do |io|
        @actors = YAML.load(io.read)
      end
    end
  end

  def save
    open(self.db_path, 'w') do |io|
      io.write(self.actors.to_yaml)
    end
  end

end
