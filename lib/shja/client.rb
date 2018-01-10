require 'hashie'

class Shja::Client
  attr_reader :agent
  attr_reader :movies
  attr_reader :target_dir
  attr_reader :db


end

class Shja::D2PassClient < Shja::Client
  attr_reader :result
  attr_reader :fault_result

  def agent_class
    raise "Unimplemented"
  end

  def movies_class
    raise "Unimplemented"
  end

  def initialize(
    username: nil,
    password: nil,
    answer: nil,
    selenium_url: nil,
    target_dir: nil
  )
    @target_dir = target_dir
    @context    = Hashie::Mash.new(
      target_dir: target_dir,
    )
    @agent      = agent_class.new(
      username: username,
      password: password,
      answer: answer,
      selenium_url: selenium_url,
      context: @context
    )
    @db         = db_class.get(@context)
    @movies     = movies_class.new(@context)

    @result       = []
    @fault_result = []
  end

end

require 'shja/client/pondo'
require 'shja/client/carib'
