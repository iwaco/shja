require 'test_helper'

class MovieManageTest < ShjaDBTest
  attr_reader :movie_manager

  def setup
    super
    @movie_manager = Shja::MovieManager.new(db)
  end

  def test_find_by_actor
    lisa_movies = [mock_movie('lisa_movie'), mock_movie('lisa_movie')]
    lisa_movies[1]['url'] = 'lisamovies2'
    serina_movies = [mock_movie('serina_movie')]
    (lisa_movies + serina_movies).each do |movie|
      movie_manager.update(movie)
    end
    lisa = mock_actor('lisa')

    actual_movies = movie_manager.find_by_actor(lisa)
    assert_equal(lisa_movies, actual_movies)
  end
end
