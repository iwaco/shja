require 'hashie'

class Shja::Client
  attr_reader :agent
  attr_reader :movies
  attr_reader :target_dir
  attr_reader :db


end

require 'shja/client/hc'
require 'shja/client/pondo'
