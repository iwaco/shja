
class Shja::Db::Carib < Shja::Db

  def compare_movie_hash(movie)
    movie['date']
  end

  def load
    @data = {  }
    if File.file?(self.db_path)
      open(self.db_path) do |io|
        @data = YAML.load(io.read)
      end
    end
  end

  def movies
    return self.data
  end

end
