require 'json'

class Shja::MovieManager::Pondo < Shja::ManagerBase

  def initialize(context)
    super
    context.movies = self
  end

  def download_index(start_page: 0, last_page: 0)
    return [].tap do |movie_ids|
      (start_page..last_page).each do |index|
        url = "http://www.1pondo.tv/dyn/ren/movie_lists/list_newest_#{index * 50}.json"
        movies = JSON.load(agent.fetch_page(url))
        movies['Rows'].each do |movie|
          movie = Shja::Movie::Pondo.new(context, movie)
          self.update(movie)
          movie_ids << movie[movie_id_key]
        end
      end
    end
  end

  def movie_id_key
    return 'MovieID'
  end

  def find(id)
    Shja::Movie::Pondo.new(context, _find(id))
  end

  def all
    _all do |movie|
      yield Shja::Movie::Pondo.new(context, movie)
    end
  end

end

class Shja::Movie::Pondo < Shja::ResourceBase

  def method_missing(method_sym, *arguments, &block)
    if @data_hash.include? camelize(method_sym.to_s)
      @data_hash[camelize(method_sym.to_s)]
    else
      super
    end
  end

  def respond_to?(method_sym, include_private = false)
    if @data_hash.include? camelize(method_sym.to_s)
      true
    else
      super
    end
  end

  def acronyms
    {
      'id' => 'ID',
      'uc' => 'UC',
      'name' => 'NAME',
    }
  end

  def camelize(term)
    string = term.to_s
    string = string.sub(/^[a-z\d]*/) { acronyms[$&] || $&.capitalize }
    string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{acronyms[$2] || $2.capitalize}" }
    string.gsub!(/\//, '::')
    string
  end

end
