$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'shja'

Shja.log.level = Logger::FATAL

require 'minitest/autorun'
require 'mocha/mini_test'
require 'securerandom'
require 'fileutils'

TMP_ROOT = File.join(File.dirname(__FILE__), '..', 'tmp')
FIXTURES_ROOT = File.join(File.dirname(__FILE__), 'fixtures')
HC_FIXTURES_ROOT = File.join(FIXTURES_ROOT, 'hc')

require 'fixtures/actors'

class ShjaDBTest < Minitest::Test
  attr_reader :target_dir
  attr_reader :db

  def setup
    @target_dir = File.join(TMP_ROOT, SecureRandom.hex(8))
    @db         = Shja::Db.get(@target_dir)
  end

  def teardown
    FileUtils.rm_r(@target_dir)
  end
end
