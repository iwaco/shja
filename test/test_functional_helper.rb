require 'yaml'
require 'rack/test'
require 'shja/server'

ENV['RACK_ENV'] = 'test'
ENV['CARIB_ETCD_PREFIX'] = "test-#{rand(10000)}"

class CaribFunctionalTest < Minitest::Test
  CLIENT = Shja::Client::Carib.new(
    username: ENV['CARIB_USERNAME'],
    password: ENV['CARIB_PASSWORD'],
    answer: ENV['CARIB_ANSWER'],
    selenium_url: ENV['CARIB_SELENIUM_URL'],
    target_dir: @target_dir
  )

  def client
    CaribFunctionalTest::CLIENT
  end

  def teardown
  end
end

class RackTest < Minitest::Test
  include Rack::Test::Methods
end

class CaribFunctionalDbTest < Minitest::Test
  attr_reader :db

  def setup
    @db = Shja::Db::Carib.new(prefix: ENV['CARIB_ETCD_PREFIX'], endpoints: ENV['CARIB_ETCD_ENDPOINTS'])
    db_fixture_path = File.join(FIXTURES_ROOT, 'carib', 'db.yml')
    open(db_fixture_path) do |io|
      YAML.load(io.read).each do |movie|
        db.save_movie(movie)
      end
    end
  end

  def teardown
    db.destroy_db!
  end
end
