require 'yaml'
require 'rack/test'
require 'shja/server'

ENV['RACK_ENV'] = 'test'
ENV['CARIB_ETCD_PREFIX'] = "test-#{rand(10000)}"

class CaribFixturesTest < Minitest::Test
  attr_reader :fixtures
  attr_reader :context
  attr_reader :target_dir

  def movie
    fixtures['movie/2017-07-18/071817-463']
  end

  def setup
    @fixtures = {}
    @target_dir ||= File.join(TMP_ROOT, SecureRandom.hex(8))
    @context    = Hashie::Mash.new(
      target_dir: @target_dir,
    )
    db_fixture_path = File.join(FIXTURES_ROOT, 'carib', 'db.yml')
    open(db_fixture_path) do |io|
      YAML.load(io.read).each do |movie|
        movie = Shja::Db::Carib::Movie.new(movie)
        @fixtures[movie.key] = Shja::Movie::Carib.new(@context, movie)
      end
    end
  end

  def teardown
    if File.directory?(target_dir)
      FileUtils.rm_rf(target_dir)
    end
  end

end

class CaribFunctionalTest < CaribFixturesTest
  CLIENT = Shja::Client::Carib.new(
    username: ENV['CARIB_USERNAME'],
    password: ENV['CARIB_PASSWORD'],
    answer: ENV['CARIB_ANSWER'],
    selenium_url: ENV['CARIB_SELENIUM_URL']
  )

  def client
    CaribFunctionalTest::CLIENT
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
