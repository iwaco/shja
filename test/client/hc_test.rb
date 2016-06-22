require 'test_helper'

class ShjaClientHcTest < ShjaHcDBTest
  attr_reader :client
  attr_reader :credential

  def setup
    super
    @credential = {
      username: 'username',
      password: 'password',
      target_dir: target_dir,
    }
    @client = Shja::Client::Hc.new(**credential)
  end

  def test_has_db
    assert_equal(db, client.db)
  end

  def test_has_actors
    assert_kind_of(Shja::ActorManager::Hc, client.actors)
    assert_equal(db, client.actors.db)
  end

  def test_has_movies
    assert_kind_of(Shja::MovieManager::Hc, client.movies)
    assert_equal(db, client.movies.db)
  end

  def test_has_agent
    assert_kind_of(Shja::Agent::Hc, client.agent)
    assert_equal(credential[:username], client.agent.username)
    assert_equal(credential[:password], client.agent.password)
  end

  def test_refresh_actors
    expected_args = { first_letter: 'A', last_letter: 'B' }
    expected_actors = [mock_hc_actor('lisa'), mock_hc_actor('serina')]

    client.agent.expects(:fetch_actors)
                .with(**expected_args)
                .returns(expected_actors)

    client.refresh_actors!(**expected_args)
    expected_actors.each_with_index do |actor, index|
      assert_equal(actor, client.db.actors[index])
    end
  end

  def test_refresh_actor
    expected_arg = 'lisa_url'
    lisa = mock_hc_actor('lisa')
    mock_hc_movies = [mock_hc_movie('lisa_movie')]
    client.agent.expects(:fetch_actor).with(expected_arg).returns(lisa)
    client.actors.expects(:update).with(lisa)
    lisa.expects(:fetch_movies).with(client.agent).returns(mock_hc_movies)
    client.movies.expects(:update).with(mock_hc_movies[0])

    client.refresh_actor(expected_arg)
  end

end
