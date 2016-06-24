class Shja::Parser::CaribPage < Shja::Parser

  def initialize(html)
    @page = Nokogiri::HTML.parse(
      html.encode(
        'utf-8', 'euc-jp', invalid: :replace, undef: :replace, replace: '?'
      )
    )
  end

end

class Shja::Parser::CaribIndexPage < Shja::Parser::CaribPage

  def parse
    page.xpath('//div[@itemtype="http://schema.org/VideoObject"]').each do |node|
      yield parse_movie_node(node)
    end
  end

  def parse_movie_node(node)
    movie = {}
    thumbnail = node.css('img[itemprop="thumbnail"]')
    movie['url'] = node.css('a[itemprop="url"]').attribute('href').value
    movie['url'] = "http://www.caribbeancom.com#{movie['url']}"
    movie['id'] = movie['url'].split('/')[-2]
    movie['thumbnail'] = thumbnail.attribute('src').value
    movie['title'] = thumbnail.attribute('title').value
    movie['date'] = node.css('span.movie-date').inner_text
    actors = node.css('span.movie-actor')
    movie['actors'] = []
    actors.css('span[itemprop="name"]').each do |actor|
      movie['actors'] << actor.inner_text
    end
    return movie
  end
end

class Shja::Parser::CaribDetailPage < Shja::Parser::CaribPage

  def parse(movie)
    movie.update(parse_movie_download_links(page))
    movie.update(parse_movie_tags(page))

    return movie
  end

  def parse_movie_download_links(movie_page)
    movie = {}
    formats = {}

    movie_page.xpath('//div[@class="download-box"]').each do |download|
      movie_resolution = download.at_css('.cc-green')
      movie_resolution = movie_resolution['class'].split(' ')
      movie_resolution.delete('cc-green')
      movie_resolution = movie_resolution.first.gsub(/^dl/, '')

      movie_box = download.at_css('.movie-download')
      if /http:\/\/.*\.mp4/ =~ movie_box.inner_html
        formats[movie_resolution] = Regexp.last_match[0]
      end
    end
    movie['movie'] = formats['720p'] || formats['1080p'] || formats['480p'] || formats['360p']
    movie['formats'] = formats
    unless movie['movie']
      Shja.log.warn "NO movie found: #{movie['url']}"
    end

    return movie
  end

  def parse_movie_tags(movie_page)
    movie = {}
    tags = []

    movie_page.css('.movie-info-cat span[itemprop="title"]').each do |tag|
      tags << tag.text
    end
    movie_page.css('.movie-info-cat a[itemprop="genre"]').each do |tag|
      tags << tag.text
    end
    movie['tags'] = tags

    return movie
  end
end
