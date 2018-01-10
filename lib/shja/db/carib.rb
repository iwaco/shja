
class Shja::Db::Carib < Shja::Db

  class Shja::Db::Carib::Movie < Hashie::Mash
    def key
      "movie/#{self.date}/#{self.id}"
    end
  end

  def initialize(prefix: 'carib', **kargs)
    super(**kargs)
    @prefix = prefix
  end

  def prefix
    @prefix
  end

  def movie_class
    Shja::Db::Carib::Movie
  end

end
