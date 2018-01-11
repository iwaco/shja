require 'test_helper'

class CaribMovieTest < CaribFixturesTest

  def test_dir_url
    assert_equal 'movies/2017-07/071817-463', movie.dir_url
  end

  def test_remote_thumbnail_url
    assert_equal 'https://tarimages.caribbeancom.com/images/flash256x144/114251.jpg', movie.remote_thumbnail_url
  end

  def test_remote_zip_url
    assert_equal 'http://www.caribbeancom.com/moviepages/071817-463/images/gallery.zip', movie.remote_zip_url
  end

  def test_photoset_dir_url
    assert_equal 'movies/2017-07/071817-463', movie.photoset_dir_url
  end

  def test_movie_url
    assert_equal 'movies/2017-07/071817-463-1080p.mp4', movie.movie_url('1080p')
  end

  def test_to_path
    assert_equal "#{target_dir}/movies/2017-07/071817-463", movie.to_path(:dir_url)
  end

end
