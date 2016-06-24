
PONDO_FIXTURES_ROOT = File.join(FIXTURES_ROOT, 'pondo')
PONDO_FAKE_RESPONSE_DIR = File.join(PONDO_FIXTURES_ROOT, 'res')
PONDO_TARGET_DIR = File.join(PONDO_FIXTURES_ROOT, 'target')

require 'fixtures/pondo/movies'

class ShjaPondoTest < Minitest::Test
  attr_reader :target_dir
  attr_reader :db
  attr_reader :agent
  attr_reader :context

  def setup
    @target_dir ||= File.join(TMP_ROOT, SecureRandom.hex(8))
    @agent      = mock('agent')
    @context    = Hashie::Mash.new(
      target_dir: @target_dir,
      agent: @agent,
    )
    @db         = Shja::Db::Pondo.get(@context)
    # @db         = Shja::Db::Pondo.get(@target_dir)
  end

  def teardown
    FileUtils.rm_r(target_dir) if File.directory?(target_dir)
  end
end
