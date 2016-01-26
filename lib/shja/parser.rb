require 'nokogiri'

class Shja::Parser

  def initialize(html)
    @page = Nokogiri::HTML.parse(html)
  end

end

require 'shja/parser/hc'
