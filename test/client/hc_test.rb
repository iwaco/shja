require 'test_helper'

class ShjaClientHcTest < ShjaDBTest
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
    assert_kind_of(Shja::ActorManager, client.actors)
    assert_equal(db, client.actors.db)
  end

  def test_has_movies
    assert_kind_of(Shja::MovieManager, client.movies)
    assert_equal(db, client.movies.db)
  end

  def test_has_agent
    assert_kind_of(Shja::Agent::Hc, client.agent)
    assert_equal(credential[:username], client.agent.username)
    assert_equal(credential[:password], client.agent.password)
  end

  def test_refresh_actors
    expected_args = { first_letter: 'A', last_letter: 'B' }
    expected_actors = [mock_actor('lisa'), mock_actor('serina')]

    client.agent.expects(:fetch_actors)
                .with(**expected_args)
                .returns(expected_actors)

    client.refresh_actors!(**expected_args)
    expected_actors.each_with_index do |actor, index|
      assert_equal(actor, client.db.actors[index])
    end
  end

end
