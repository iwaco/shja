$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'shja'

Shja.log.level = Logger::FATAL

require 'minitest/autorun'
require 'mocha/mini_test'
require 'securerandom'

TMP_ROOT = File.join(File.dirname(__FILE__), '..', 'tmp')
FIXTURES_ROOT = File.join(File.dirname(__FILE__), 'fixtures')

require 'test_pondo_helper'
require 'test_functional_helper'
