require_relative '../../test_helper'

class DbCaribFunctionalDbTest < CaribFunctionalDbTest

  def test_get_movie
    movie = db.get_movie("movie/2017-08-24/082417-001")
    assert_kind_of Shja::Db::Carib::Movie, movie
    assert_equal '082417-001', movie.id
    assert_equal 'https://tarimages.caribbeancom.com/images/flash256x144/114747.jpg', movie.thumbnail
  end

  def test_find_movies
    movies = db.find_movies("movie/2017-07")
    movies.each do |movie|
      assert_match /2017-07-\d{2}/, movie.date
    end
    assert_equal 8, movies.size
  end

end
