
class Shja::MovieManager::Carib < Shja::MovieManager

  def download_index(start_page: 0, last_page: 0)
    agent.login
    (start_page..last_page).each do |index|
      index += 1
      url = "http://www.caribbeancom.com/listpages/all#{index}.htm"
      Shja.log.debug("Fetch Index: #{url}")
      html = agent.fetch_page(url)

      Shja::Parser::CaribIndexPage.new(html).parse do |movie|
        Shja.log.debug("Processing: #{movie['title']}")
        begin
          _find(movie['id'])
        rescue
          Shja.log.debug("Detail not found: #{movie['url']}")
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

  def download_metadata
    mkdir
    self._download("http://www.caribbeancom.com#{thumbnail}", thumbnail_url)
    self._download(remote_zip_url, zip_url)

    extract_zip
    create_symlink(:zip_url)
    create_symlink(:thumbnail_url)
  end

  def create_symlink url_sym
    to = to_path(self.send(url_sym))
    from = to_path(self.send(url_sym, false))
    path_to = Pathname(to)
    path_from = Pathname(File.dirname(from))

    Shja.log.debug("Create symlink #{from} to #{to}")
    relative_path = path_to.relative_path_from(path_from).to_s
    begin
      FileUtils.rm(from, { force: true })
      if File.exist?(to)
        FileUtils.mkdir_p(File.dirname(from.to_s))
        File.symlink(relative_path, from)
      end
    rescue Errno::EEXIST
    end
  end

  def extract_zip
    zip_path = to_path(zip_url)
    return if File.file?(zip_path)

    photoset_dir_path = to_path(photoset_dir_url)
    FileUtils.mkdir_p(photoset_dir_path)

    Zip::File.open(zip_path) do |zip|
      zip.each do |entry|
        basename = File.basename(entry.name)
        if File.extname(basename) == '.jpg'
          entry_path = File.join(photoset_dir_path, basename)
          unless File.file?(entry_path)
            zip.extract(entry, entry_path) { true }
          end
        end
      end
    end
  rescue => ex
    Shja.log.warn("Failed extract zip: #{zip_url}")
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
