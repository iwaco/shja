$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'shja'

require 'minitest/autorun'
require 'mocha/mini_test'

FIXTURES_ROOT = File.join(File.dirname(__FILE__), 'fixtures')
HC_FIXTURES_ROOT = File.join(FIXTURES_ROOT, 'hc')
