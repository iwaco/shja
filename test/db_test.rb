require 'test_helper'

class ShjaDBTest < Minitest::Test
  attr_reader :db

  def setup_existing_db
    @db = Shja::Db.new(FIXTURES_ROOT)
  end

  def test_load
    db = setup_existing_db
    assert_equal(4, db.movies.size)
  end

end
