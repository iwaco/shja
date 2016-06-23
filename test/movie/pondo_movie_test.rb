require 'test_helper'

class PondoMovieTest < ShjaPondoTest
  attr_reader :movie

  def setup
    super
    @movie = mock_pondo_movie('mari_movie')
  end

  def test_enable_snake_case_attributes
    assert_equal(movie['MovieID'], movie.movie_id)
    assert_equal(movie['UCNAME'], movie.uc_name)
  end

  def test_to_path_with_sym
    assert_equal(
      File.join(context.target_dir, "2016-06/061516_317"),
      movie.to_path(:dir_url)
    )
  end

  def test_to_path
    assert_equal(
      File.join(context.target_dir, "2016-06/061516_317"),
      movie.to_path(movie.dir_url)
    )
  end

  def test_dir_url
    assert_equal("2016-06/061516_317", movie.dir_url)
  end

  def test_thumbnail_url
    assert_equal("2016-06/061516_317.jpg", movie.thumbnail_url)
  end

  def test_photoset_metadata_url
    assert_equal("2016-06/061516_317/photoset_metadata.json", movie.photoset_metadata_url)
  end

  def test_metadata_url
    assert_equal("2016-06/061516_317/metadata.json", movie.metadata_url)
  end

  def test_photoset_metadata_real_url
    assert_equal("http://www.1pondo.tv/dyn/ren/movie_galleries/3440.json", movie.photoset_metadata_remote_url)
  end

  def test_metadata_real_url
    assert_equal("http://www.1pondo.tv/dyn/ren/movie_details/3440.json", movie.metadata_remote_url)
  end

end
