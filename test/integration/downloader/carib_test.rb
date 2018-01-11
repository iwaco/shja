require_relative '../../test_helper'

class DownloaderCaribFunctionalTest < CaribFunctionalTest
  attr_reader :downloader

  def setup
    super
    @downloader = Shja::Downloader::Carib.new(client)
  end

  def test_download_metadata
    downloader.download_metadata(movie)
    assert File.file?(movie.to_path(:thumbnail_url))
    assert File.file?(movie.to_path(:zip_url))
    assert File.size(movie.to_path(:zip_url)) > 0
  end

end
