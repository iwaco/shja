require 'test_helper'

class MovieManageTest < ShjaDBTest
  attr_reader :movie_manager
  attr_reader :actor_manager

  def setup
    super
    @actor_manager = Shja::ActorManager::Hc.new(db, target_dir)
    @movie_manager = Shja::MovieManager::Hc.new(db, actor_manager)
  end

  def test_find_by_actor
    lisa = mock_actor('lisa')
    serina = mock_actor('serina')
    actor_manager.update(lisa)
    actor_manager.update(serina)
    lisa_movies = [mock_movie('lisa_movie'), mock_movie('lisa_movie')]
    lisa_movies[1]['url'] = 'lisamovies2'
    serina_movies = [mock_movie('serina_movie')]
    (lisa_movies + serina_movies).each do |movie|
      movie_manager.update(movie)
    end

    actual_movies = movie_manager.find_by_actor(lisa)
    assert_equal(lisa_movies, actual_movies)
  end
end
