
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
