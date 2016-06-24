require 'nokogiri'

class Shja::Parser
  attr_reader :page

  def initialize(html)
    @page = Nokogiri::HTML.parse(html)
  end

end

require 'shja/parser/hc'
require 'shja/parser/carib'
