require 'test_helper'

class MovieManageTest < ShjaHcDBTest
  attr_reader :movie_manager
  attr_reader :actor_manager

  def setup
    super
    @context        = Hashie::Mash.new(db: db, target_dir: target_dir)
    @actor_manager  = Shja::ActorManager::Hc.new(@context)
    @movie_manager  = Shja::MovieManager::Hc.new(@context)
  end

  def _setup_lisa_movies
    lisa = mock_hc_actor('lisa')
    actor_manager.update(lisa)
    lisa_movies = [mock_hc_movie('lisa_movie'), mock_hc_movie('lisa_movie2')]
    (lisa_movies).each do |movie|
      movie_manager.update(movie)
    end
    return [lisa, lisa_movies]
  end

  def test_all
    _setup_lisa_movies

    movie_manager.all do |movie|
      assert_equal('Lisa', movie.actor.name)
    end
  end

  def test_find
    lisa, lisa_movies = _setup_lisa_movies

    movie = movie_manager.find('lisa_movie')
    assert_equal(lisa_movies[0], movie)
    assert_equal(lisa.id, movie.actor.id)
  end

  def test_find_by_actor
    lisa, lisa_movies = _setup_lisa_movies
    serina = mock_hc_actor('serina')
    actor_manager.update(serina)
    serina_movies = [mock_hc_movie('serina_movie')]
    (lisa_movies + serina_movies).each do |movie|
      movie_manager.update(movie)
    end

    actual_movies = movie_manager.find_by_actor(lisa)
    assert_equal(lisa_movies, actual_movies)
  end
end
