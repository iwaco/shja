
class Shja::Db::Hc < Shja::Db

  def load
    @data = {
      'actors' => [],
      'movies' => []
    }
    if File.file?(self.db_path)
      open(self.db_path) do |io|
        @data = YAML.load(io.read)
        @data['actors'].map! {|e| Shja::Actor::Hc.new(e) }
        @data['movies'].map! {|e| Shja::Movie::Hc.new(e) }
      end
    end
  end

  def actors
    return self.data['actors']
  end

  def movies
    return self.data['movies']
  end

  def save
    open(self.db_path, 'w') do |io|
      _data = {}
      _data['actors'] = self.actors.map { |e| e.to_h }
      _data['movies'] = self.movies.map { |e| e.to_h }
      io.write(_data.to_yaml)
    end
  end

end
