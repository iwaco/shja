
class Shja::Movie::Carib < Shja::Movie

  def method_missing(name, *args, **kwargs)
    if base.include?(name.to_s)
      base.send(name, *args, **kwargs)
    else
      super
    end
  end

  def key
    base.key
  end

  def actor?(name)
    self.actors.each do |actor|
      if actor.include?(name)
        return true
      end
    end
    return false
  end

  def supported_formats
    ['1080p', '720p', '480p', '360p', '240p']
  end

  def default_format
    supported_formats.each do |f|
      return f if self.formats.include?(f)
    end
    raise "No format found!!"
  end

  def remote_thumbnail_url
    if self.thumbnail.start_with?('http')
      return self.thumbnail
    else
      return "http://www.caribbeancom.com#{thumbnail}"
    end
  end

  def remote_zip_url
    "http://www.caribbeancom.com/moviepages/#{self.id}/images/gallery.zip"
  end

  def photoset_dir_url
    return "#{dir_url()}"
  end

  def movie_url format
    return "#{dir_url()}-#{format}.mp4"
  end

  def zip_url
    return "#{dir_url()}.zip"
  end

  def thumbnail_url
    return "#{dir_url()}.jpg"
  end

  def dir_url
    return "#{top_dir_url()}/#{id}"
  end

  def top_dir_url
    return "movies/#{self.date.split('-')[0, 2].join('-')}"
  end

end
