require 'test_helper'

class CaribRackTest < RackTest
  def app
    Shja::Server::Carib
  end

  def setup
    db_fixture_path = File.join(FIXTURES_ROOT, 'carib', 'db.yml')
    open(db_fixture_path) do |io|
      YAML.load(io.read).each do |movie|
        app.db.save_movie(movie)
      end
    end
  end

  def teardown
    app.db.destroy_db!
  end

  def test_root
    get '/'
    assert last_response.ok?
  end

  def test_movies
    get '/api/movies/2018'
    movies = JSON.load(last_response.body)
    movies.each do |movie|
      assert_match /2018-\d{2}-\d{2}/, movie['date']
      assert movie['title']
    end
  end

end
