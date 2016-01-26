require 'test_helper'

class ShjaDBTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Shja::VERSION
  end

end
