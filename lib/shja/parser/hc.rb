
HC_BASE_URL = "http://ex.shemalejapanhardcore.com"

class Shja::Parser::HcIndexPage < Shja::Parser
  def parse_actors
    page = @page
    return [].tap do |models|
      page.css('div.model').each do |data|
        model = {}
        h4 = data.at_css('h4 a')
        model['name'] = h4.content.strip
        model['url']  = h4['href']
        model['id'] = File.basename(model['url'], '.html')
        photo = data.at_css('div.modelphoto img.thumbs')
        model['thumbnail'] = File.join(HC_BASE_URL, photo['src'])
        models << model
      end
    end
  end

  def parse_pagination
    page = @page
    return [].tap do |pages|
      page.css('div.pagination li a').each do |data|
        Shja.log.debug(data['href'].strip)
        pages << data['href'].strip
      end
    end
  end

end

class Shja::Parser::HcActorPage < Shja::Parser

  def parse_actor
    page = @page
    return {}.tap do |actor|
      actor['name']       = page.at_css('.model_details h3').content.strip
      photo = page.at_css('div.model_photo img.thumbs')
      actor['thumbnail'] = File.join(HC_BASE_URL, photo['src'])
    end
  end

  def parse_movies
    page = @page
    photosets, movies = _split_photoset_and_movie(page)
    unless photosets.size == movies.size
      raise "Invalid photosets size: #{photosets.size}, movies size: #{movies.size}"
    end

    [].tap do |rtn|
      movies.size.times do |i|
        m = movies[i]
        z = photosets[i]
        z['photoset_url'] = z['url']
        rtn << z.update(m)
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
      # rtn['actor'] = set.at_css('.modelname center').content.strip
      rtn['title'] = set.at_css('h4 a').content.strip
      rtn['url'] = set.at_css('.videohere a.update_title')['href']
      rtn['thumbnail'] = set.at_css('.videohere img.thumbs')['src']
      rtn['thumbnail'] = File.join(HC_BASE_URL, rtn['thumbnail'])
      rtn['date'] = Date.parse(set.at_css('p.dateadded').content.strip)
      rtn
    end
  end
end

class Shja::Parser::HcZipPage < Shja::Parser

  def parse_zip_url
    page = @page
    url = page.at_css('div.video_photos_zips a.memberdownload')['href']
    "#{HC_BASE_URL}#{url}"
  end

  def parse_pictures
    page = @page
    pictures = []
    page.css('div.indphoto .photo_thumb_container a.fancybox').each do |img|
      href = img['href']
      unless href.start_with?(HC_BASE_URL)
        href = "#{HC_BASE_URL}#{href}"
      end
      pictures << href
    end
    other_pages = []
    page.css('div.pagination li.num a.pagenav').each do |num|
      href = num['href']
      unless href.start_with?(HC_BASE_URL)
        href = "#{HC_BASE_URL}#{href}"
      end
      other_pages << href
    end
    return {
      pictures: pictures,
      pages: other_pages
    }
  end
end

class Shja::Parser::HcMoviePage < Shja::Parser

  def parse
    {}.tap do |formats|
      page = @page
      div = page.at_css('div.video_size_outer div.movie_sizes')
      div.css('a.full_download_link').each do |f|
        format = f.content.split()[0].strip.downcase
        formats[format] = File.join(HC_BASE_URL, f['href'])
      end
      Shja.log.info("Movie isn't detected") if formats.size == 0
    end
  end

end
