require 'test_helper'

class MovieManageTest < ShjaDBTest
  attr_reader :movie_manager

  def setup
    super
    @movie_manager = Shja::MovieManager.new(db)
  end
end

class MovieTest < Minitest::Test

  def test_set_actor
    actor = mock_actor('serina')
    movie = mock_movie('lisa_movie')

    movie.actor = actor
    assert_equal(actor.id, movie.actor_id)
  end

end
