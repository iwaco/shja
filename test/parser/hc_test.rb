require 'test_helper'

class ShjaParserHcTest < Minitest::Test

  HC_FIXTURES_ROOT = File.join(FIXTURES_ROOT, 'hc')

  def setup
    @parser = Shja::Parser::Hc.new
    @lisa_html = open(File.join(HC_FIXTURES_ROOT, 'lisa.html')).read
    @page = Nokogiri::HTML.parse(@lisa_html)
  end

  def test_parse_actor_page
    movies = @parser.parse_actor_page(@lisa_html)
    assert_kind_of(Array, movies)
    assert_equal(5, movies.size)
    movies.each do |movie|
      assert_kind_of(Shja::Movie, movie)
    end
  end

  def test__split_photoset_and_movie
    divs = @parser._split_photoset_and_movie(@page)
    assert_equal(2, divs.size)
  end

  TITLES = [
    "Girl Next Door Lisa",
    "Lisa's After School Delight",
    "Lisa's Stimulating Guys",
    "Friends With Benefits For Lisa",
    "Down-To-Earth Lisa",
  ]
  PHOTOSET_URLS = [
    "http://ex.shemalejapanhardcore.com/members/scenes/Girl-Next-Door-Lisa_highres.html",
    "http://ex.shemalejapanhardcore.com/members/scenes/Lisas-After-School-Delight_highres.html",
    "http://ex.shemalejapanhardcore.com/members/scenes/Lisas-Stimulating-Guys_highres.html",
    "http://ex.shemalejapanhardcore.com/members/scenes/Friends-With-Benefits-For-Lisa_highres.html",
    "http://ex.shemalejapanhardcore.com/members/scenes/Down-To-Earth-Lisa_highres.html",
  ]
  MOVIE_URLS = [
    "http://ex.shemalejapanhardcore.com/members/scenes/Girl-Next-Door-Lisa_vids.html",
    "http://ex.shemalejapanhardcore.com/members/scenes/Lisas-After-School-Delight_vids.html",
    "http://ex.shemalejapanhardcore.com/members/scenes/Lisas-Stimulating-Guys_vids.html",
    "http://ex.shemalejapanhardcore.com/members/scenes/Friends-With-Benefits-For-Lisa_vids.html",
    "http://ex.shemalejapanhardcore.com/members/scenes/Down-To-Earth-Lisa_vids.html",
  ]
  THUMBNAILS = [
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/4427.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/4435.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/4447.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/4455.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/4462.jpg",
  ]
  DATES = [
    "2013-04-04",
    "2012-10-25",
    "2012-08-16",
    "2012-01-06",
    "2011-02-04",
  ]

  def test__parse_photosets
    sets, _ = @page.css('div.pattern_span')
    sets = @parser._parse_set_div(sets)
    assert_equal(5, sets.size)
    sets.each_with_index do |set, i|
      assert_kind_of(Hash, set)
      assert_equal('Lisa', set['actor'])
      assert_equal(TITLES[i], set['title'])
      assert_equal(PHOTOSET_URLS[i], set['url'])
      assert_equal(DATES[i], set['date'].to_s)
    end
  end

  def test__parse_set_div
    _, sets = @page.css('div.pattern_span')
    sets = @parser._parse_set_div(sets)
    assert_equal(5, sets.size)
    sets.each_with_index do |set, i|
      assert_kind_of(Hash, set)
      assert_equal('Lisa', set['actor'])
      assert_equal(TITLES[i], set['title'])
      assert_equal(MOVIE_URLS[i], set['url'])
      assert_equal(DATES[i], set['date'].to_s)
    end
  end

end
