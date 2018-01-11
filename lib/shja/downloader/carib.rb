
class Shja::Downloader::Carib < Shja::Downloader

  def download_movie(movie, format)
    format = movie.default_format unless format
    remote_movie_url = movie.formats[format]
    local_movie_url = movie.movie_url(format)
    Shja.log.info("Movie download: #{movie.title}, #{remote_movie_url}")

    return raw_download(remote_movie_url, movie.to_path(local_movie_url), ignore_error: true)
  end

  def download_metadata(movie)
    mkdir(movie)
    raw_download(movie.remote_thumbnail_url, movie.to_path(:thumbnail_url), ignore_error: true)
    raw_download(movie.remote_zip_url, movie.to_path(:zip_url), ignore_error: true)

    extract_zip(movie)
  end

  def mkdir(movie)
    dir_path = movie.to_path(:dir_url)
    unless File.directory?(dir_path)
      FileUtils.mkdir_p(dir_path)
    end
  end

  def extract_zip(movie)
    return if movie.has_pictures?

    zip_path = movie.to_path(:zip_url)
    return unless File.file?(zip_path)
    photoset_dir_path = movie.to_path(:photoset_dir_url)
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
    FileUtils.rm(zip_path) if File.file?(zip_path)
  end

end
