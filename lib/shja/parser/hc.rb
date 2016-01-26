require 'nokogiri'

class Shja::Parser::HcActorPage

  def parse(html)
    page = Nokogiri::HTML.parse(html)
    photosets, movies = _split_photoset_and_movie(page)
    unless photosets.size == movies.size
      raise "Invalid photosets size: #{photosets.size}, movies size: #{movies.size}"
    end

    [].tap do |rtn|
      movies.size.times do |i|
        m = movies[i]
        z = photosets[i]
        z['photoset_url'] = z['url']
        rtn << Shja::Movie.new(z.update(m))
      end
    end
  end

  def _split_photoset_and_movie(page)
    divs = page.css('div.pattern_span')
    raise 'Invalid page: photosets and movies aren\'t detected' unless divs.size == 2
    [_parse_set_div(divs[0]), _parse_set_div(divs[1])]
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
