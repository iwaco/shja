
HC_FIXTURES_ROOT = File.join(FIXTURES_ROOT, 'hc')
HC_TARGET_DIR = File.join(HC_FIXTURES_ROOT, 'target')

require 'fixtures/hc/actors'
require 'fixtures/hc/movies'

class ShjaHcDBTest < Minitest::Test
  attr_reader :target_dir
  attr_reader :context
  attr_reader :db

  def setup
    @target_dir = File.join(TMP_ROOT, SecureRandom.hex(8))
    @context    = Hashie::Mash.new(target_dir: @target_dir)
    @db         = Shja::Db::Hc.get(@context)
  end

  def teardown
    FileUtils.rm_r(@target_dir)
  end
end
