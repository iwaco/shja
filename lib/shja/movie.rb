require 'json'
require 'fastimage'

class Shja::Movie
  attr_reader :context
  attr_reader :base

  def initialize(context, base)
    @context = context
    @base = base
  end

  def updated_date
    movie_path = to_path(movie_url(default_format))
    if File.file?(movie_path)
      return File.mtime(movie_path).strftime("%Y-%m-%d")
    else
      return nil
    end
  rescue => ex
    Shja.log.info("Fail to retrieve update_date: #{id}, #{ex.message}")
    return nil
  end

  def target_dir
    context.target_dir
  end

  def exists?(format=nil)
    format = default_format unless format
    movie_path = to_path(movie_url(format))

    file_exists?(movie_path)
  end

  def to_path(url_sym_or_str)
    if url_sym_or_str.kind_of?(Symbol)
      url_sym_or_str = self.send(url_sym_or_str)
    end
    return File.join(target_dir, url_sym_or_str)
  end

  def actor?
    raise "Unimplemented"
  end

  def pictures_path
    Dir.glob(File.join(to_path(photoset_dir_url), '*.jpg'))
       .sort {|a, b| File.basename(a, ".*").to_i <=>  File.basename(b, ".*").to_i }
  end

  def has_pictures?
    pictures_path.size > 0
  end

  def pictures_metadata
    return pictures_path.map do |image|
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

require 'shja/movie/pondo'
require 'shja/movie/carib'
