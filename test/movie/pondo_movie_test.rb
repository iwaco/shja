require 'test_helper'

class PondoMovieTest < ShjaPondoTest

  def test_enable_snake_case_attributes
    movie = mock_pondo_movie('mari_movie')

    assert_equal(movie['MovieID'], movie.movie_id)
    assert_equal(movie['UCNAME'], movie.uc_name)
  end

end
