require 'yaml'

class Shja::Db
  attr_reader :db_path
  attr_reader :data

  # TODO: test
  @@dbs = {}
  def self.get(context)
    @@dbs[context.target_dir] ||= self.new(context.target_dir)
    context.db = @@dbs[context.target_dir]
    return @@dbs[context.target_dir]
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
      'movies' => []
    }
    if File.file?(self.db_path)
      open(self.db_path) do |io|
        @data = YAML.load(io.read)
      end
    end
  end

  def movies
    return self.data['movies']
  end

  def compare_movie_hash(movie)
    raise 'Unimplemented'
  end

  def save
    self.movies.sort_by! do |movie|
      compare_movie_hash(movie)
    end
    self.movies.reverse!
    open(self.db_path, 'w') do |io|
      io.write(@data.to_yaml)
    end
  end

end

require 'shja/db/hc'
require 'shja/db/pondo'
require 'shja/db/carib'
