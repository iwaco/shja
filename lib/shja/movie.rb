require 'json'
require 'speedpetal'
require 'zip'
require 'fastimage'

class Shja::MovieManager < Shja::ManagerBase

  def initialize(context)
    super
    context.movies = self
  end

  def _all
    self.db.movies.each do |movie|
      yield movie
    end
  end

  def movie_id_key
    return 'id'
  end

  def _find(id)
    self.db.movies.find{|e| e[movie_id_key] == id }.tap do |movie|
      raise "Movie not found: #{id}" unless movie
    end
  end

  def update(movie)
    _movie = self.db.movies.find{|e| e[movie_id_key] == movie[movie_id_key] }
    movie = movie.to_h
    if _movie
      _movie.update(movie)
    else
      self.db.movies << movie
    end
  end

end

class Shja::Movie < Shja::ResourceBase

  def updated_date
    movie_path = to_path(movie_url(default_format))
    if File.file?(movie_path)
      return File.mtime(movie_path).strftime("%Y-%m-%d")
    else
      return nil
    end
  end

  def mkdir
    dir_path = to_path(:dir_url)
    unless File.directory?(dir_path)
      FileUtils.mkdir_p(dir_path)
    end
  end

  def _download(from, to, ignore_error: false, unexpected_types: ['html'])
    if from.kind_of?(Symbol)
      from = self.send(from)
    end
    to = to_path(to)
    unless File.file?(to)
      return agent.download(from, to, unexpected_types)
    end
    return false
  rescue => ex
    if ignore_error
      Shja.log.error(ex.message)
      Shja.log.error(ex.backtrace.join("\n"))
      return false
    else
      raise ex
    end
  end

  def to_path(url_sym_or_str)
    if url_sym_or_str.kind_of?(Symbol)
      url_sym_or_str = self.send(url_sym_or_str)
    end
    return File.join(target_dir, url_sym_or_str)
  end

  def photoset_dir_path
    to_path(photoset_dir_url)
  end

  def actor?
    raise "Unimplemented"
  end

  def pictures_path
    raise "Unimplemented"
  end

  def has_pictures?
    pictures_path.size > 0
  end

  def pictures_metadata
    return pictures_path.sort.map do |image|
      basename = File.basename(image)
      size = ::FastImage.size(image)
      if size
        {
          "name" => basename,
          "w" => size[0],
          "h" => size[1]
        }
      else
        Shja::log.warn("Image can't detect size: #{image}")
        nil
      end
    end.compact
  end

end

require 'shja/movie/hc'
require 'shja/movie/pondo'
require 'shja/movie/carib'
