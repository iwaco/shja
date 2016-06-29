
class Shja::MovieManager::Carib < Shja::MovieManager

  def download_index(start_page: 0, last_page: 0)
    agent.login
    (start_page..last_page).each do |index|
      index += 1
      url = "http://www.caribbeancom.com/listpages/all#{index}.htm"
      Shja.log.info("Fetch Index: #{url}")
      html = agent.fetch_page(url)

      Shja::Parser::CaribIndexPage.new(html).parse do |movie|
        Shja.log.info("Processing: #{movie['title']}")
        begin
          _find(movie['id'])
        rescue
          Shja.log.info("Loading Detail for: #{movie['url']}")
          html = agent.fetch_page(movie['url'])
          Shja::Parser::CaribDetailPage.new(html).parse(movie)
        end
        movie = Shja::Movie::Carib.new(context, movie)
        self.update(movie)
        movie.download_metadata
      end
    end
    self.db.save
  end

  def find(id)
    Shja::Movie::Carib.new(context, _find(id))
  end

  def all
    _all do |movie|
      yield Shja::Movie::Carib.new(context, movie)
    end
  end

end

class Shja::Movie::Carib < Shja::Movie

  def download(format)
    Shja.log.debug("Download start: #{dir_url}")
    download_metadata
    return download_movie(format)
  end

  def download_metadata
    mkdir
    self._download(remote_thumbnail_url, thumbnail_url, ignore_error: true)
    self._download(remote_zip_url, zip_url, ignore_error: true)

    extract_zip
  end

  def download_movie(format)
    format = default_format unless format
    remote_movie_url = self.formats[format]
    local_movie_url = movie_url(format)
    Shja.log.info("Movie download: #{title}, #{remote_movie_url}")

    return self._download(remote_movie_url, local_movie_url)
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

  def create_symlinks
    create_symlink(:dir_url)
    create_symlink(:zip_url)
    create_symlink(:thumbnail_url)
    supported_formats.each do |format|
      create_symlink(:movie_url, format)
    end
  end

  def create_symlink url_sym, format=nil
    unless format
      to = to_path(self.send(url_sym))
      from = to_path(self.send(url_sym, false))
    else
      to = to_path(self.send(url_sym, format))
      from = to_path(self.send(url_sym, format, false))
    end
    return unless File.exist?(to)
    Shja.log.debug("Create symlink #{from} to #{to}")

    path_to = Pathname(to)
    path_from = Pathname(File.dirname(from))

    relative_path = path_to.relative_path_from(path_from).to_s
    begin
      FileUtils.rm(from, { force: true })
      FileUtils.mkdir_p(File.dirname(from.to_s))
      File.symlink(relative_path, from)
    rescue Errno::EEXIST
    end
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

  def photoset_dir_url real=true
    return "#{dir_url(real)}"
  end

  def movie_url format, real=true
    return "#{dir_url(real)}-#{format}.mp4"
  end

  def zip_url real=true
    return "#{dir_url(real)}.zip"
  end

  def thumbnail_url real=true
    return "#{dir_url(real)}.jpg"
  end

  def dir_url real=true
    if real
      basename = "#{self.actors.join(' ')} #{self.title}"
      return "#{top_dir_url}/#{basename}"
    else
      return "#{top_dir_url(false)}/#{id}"
    end
  end

  def top_dir_url real=true
    if real
      return self.date.split('-')[0, 2].join('-')
    else
      return "movies/#{top_dir_url}"
    end
  end

end
