require 'nokogiri'

class Shja::Parser::Hc

  def parse_actor_page(html)
    page = Nokogiri::HTML.parse(html)
    photosets, movies = _split_photoset_and_movie(page)
    [].tap do |movies|
      movies << Shja::Movie.new({})
      movies << Shja::Movie.new({})
      movies << Shja::Movie.new({})
      movies << Shja::Movie.new({})
      movies << Shja::Movie.new({})
    end
  end

  def _split_photoset_and_movie(page)
    divs = page.css('div.pattern_span')
    raise 'Invalid page: photosets and movies aren\'t detected' unless divs.size == 2
    divs
  end

  def _parse_set_div(div)
    div.css('div.sexyvideo').map do |set|
      rtn = {}
      rtn['actor'] = set.at_css('.modelname center').content.strip
      rtn['title'] = set.at_css('h4 a').content.strip
      rtn['url'] = set.at_css('.videohere a.update_title')['href']
      # puts "\"#{set.at_css('.videohere a.update_title')['href']}\","
      rtn['thumbnail'] = set.at_css('.videohere img.thumbs')['src']
      rtn['thumbnail'] = "http://ex.shemalejapanhardcore.com" + rtn['thumbnail']
      rtn['date'] = Date.parse(set.at_css('p.dateadded').content.strip)
      # puts "\"#{Date.parse(set.at_css('p.dateadded').content.strip)}\","
      rtn
    end
  end
end
