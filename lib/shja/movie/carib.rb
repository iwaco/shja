
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

  def photoset_dir_url real=true
    return "#{dir_url(real)}"
  end

  def movie_url format, real=true
    return "#{dir_url(real)}-#{format}.mp4"
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
