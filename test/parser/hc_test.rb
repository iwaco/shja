require 'test_helper'


HC_FIXTURES_ROOT = File.join(FIXTURES_ROOT, 'hc')

class ShjaParserHcIndexPageTest < Minitest::Test
  def setup
    @index_page = open(File.join(HC_FIXTURES_ROOT, 'models.2.html')).read
    @parser = Shja::Parser::HcIndexPage.new(@index_page)
  end

  NAMES = [
    "Sabina Sinn",
    "Sable",
    "Sabrina Alvez",
    "Sabrina Xavier and Rafa",
    "Sai & Alice",
    "Saki",
    "Sasha Skyes",
    "Saya Koda",
    "Sayaka",
    "Sayaka Ayasaki",
    "Sayaka Kohaku",
    "Sayaka Taniguchi",
    "Seira Mikami",
    "Sena Kasaiwazaki",
    "Serina",
    "Sharon Fox & Bruno",
    "Shay",
    "Sheeba",
    "Shiho Kanda",
    "Shion Suzuhara",
    "Shizuka Momose",
    "Sienna Grace",
    "Sofia Ferreira",
    "Sofie",
  ]

  IDS = [
    "sabina-sinn",
    "sable",
    "sabrina-alvez",
    "sabrina-xavier-and-rafa",
    "sai--alice",
    "saki",
    "sasha-skyes",
    "saya-koda",
    "sayaka",
    "sayaka-ayasaki",
    "sayaka-kohaku",
    "sayaka-taniguchi",
    "seira-mikami",
    "sena-kasaiwazaki",
    "serina",
    "sharon-fox--bruno",
    "shay",
    "sheeba",
    "shiho-kanda",
    "shion-suzuhara",
    "shizuka-momose",
    "sienna-grace",
    "sofia-ferreira",
    "sofie",
  ]

  URLS = [
    "http://ex.shemalejapanhardcore.com/members/models/sabina-sinn.html",
    "http://ex.shemalejapanhardcore.com/members/models/sable.html",
    "http://ex.shemalejapanhardcore.com/members/models/sabrina-alvez.html",
    "http://ex.shemalejapanhardcore.com/members/models/sabrina-xavier-and-rafa.html",
    "http://ex.shemalejapanhardcore.com/members/models/sai--alice.html",
    "http://ex.shemalejapanhardcore.com/members/models/saki.html",
    "http://ex.shemalejapanhardcore.com/members/models/sasha-skyes.html",
    "http://ex.shemalejapanhardcore.com/members/models/saya-koda.html",
    "http://ex.shemalejapanhardcore.com/members/models/sayaka.html",
    "http://ex.shemalejapanhardcore.com/members/models/sayaka-ayasaki.html",
    "http://ex.shemalejapanhardcore.com/members/models/sayaka-kohaku.html",
    "http://ex.shemalejapanhardcore.com/members/models/sayaka-taniguchi.html",
    "http://ex.shemalejapanhardcore.com/members/models/seira-mikami.html",
    "http://ex.shemalejapanhardcore.com/members/models/sena-kasaiwazaki.html",
    "http://ex.shemalejapanhardcore.com/members/models/serina.html",
    "http://ex.shemalejapanhardcore.com/members/models/sharon-fox--bruno.html",
    "http://ex.shemalejapanhardcore.com/members/models/shay.html",
    "http://ex.shemalejapanhardcore.com/members/models/sheeba.html",
    "http://ex.shemalejapanhardcore.com/members/models/shiho-kanda.html",
    "http://ex.shemalejapanhardcore.com/members/models/shion-suzuhara.html",
    "http://ex.shemalejapanhardcore.com/members/models/shizuka-momose.html",
    "http://ex.shemalejapanhardcore.com/members/models/sienna-grace.html",
    "http://ex.shemalejapanhardcore.com/members/models/sofia-ferreira.html",
    "http://ex.shemalejapanhardcore.com/members/models/sofie.html",
  ]

  THUMBNAILS = [
    "http://ex.shemalejapanhardcore.com/images/p16.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2902-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2904-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2906-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2908-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2910-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/3176-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2912-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2915-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2917-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2918-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2921-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2923-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/3138-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2927-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/3140-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2930-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2932-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2935-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2936-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2938-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2940-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/3142-set.jpg",
    "http://ex.shemalejapanhardcore.com/members/content/contentthumbs/2944-set.jpg",
  ]

  def test_parse
    actors = @parser.parse_actors
    assert_equal(NAMES.size, actors.size)

    actors.each_with_index do |actor, i|
      assert_equal(IDS[i], actor['id'])
      assert_equal(NAMES[i], actor['name'])
      assert_equal(URLS[i], actor['url'])
      assert_equal(THUMBNAILS[i], actor['thumbnail'])
    end
  end

end

class ShjaParserHcActorPageTest < Minitest::Test

  def setup
    @lisa_html = open(File.join(HC_FIXTURES_ROOT, 'lisa.html')).read
    @parser = Shja::Parser::HcActorPage.new(@lisa_html)
    @page = Nokogiri::HTML.parse(@lisa_html)
  end

  def test_parse
    movies = @parser.parse
    assert_kind_of(Array, movies)
    assert_equal(5, movies.size)
    movies.each_with_index do |movie, i|
      assert_kind_of(Shja::Movie, movie)
      assert_equal('Lisa', movie['actor'])
      assert_equal(TITLES[i], movie['title'])
      assert_equal(PHOTOSET_URLS[i], movie['photoset_url'])
      assert_equal(MOVIE_URLS[i], movie['url'])
      assert_equal(DATES[i], movie['date'].to_s)
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

class ShjaParserHcZipPageTest < Minitest::Test

  def setup
    @zip_html = open(File.join(HC_FIXTURES_ROOT, 'uta.zip.html')).read
    @parser = Shja::Parser::HcZipPage.new(@zip_html)
  end

  def test_parse
    zip_url = @parser.parse
    assert_equal('http://ex.shemalejapanhardcore.com/members/content/upload/uta/151224/151224_1440highres.zip', zip_url)
  end

end

class ShjaParserHcMoviePageTest < Minitest::Test

  FORMATS = {
    "360p" => "http://ex.shemalejapanhardcore.com/members/content/upload/uta/151224//360p/utatbhc1_1_hdmp4.mp4",
    "480p" => "http://ex.shemalejapanhardcore.com/members/content/upload/uta/151224//480p/utatbhc1_1_hdmp4.mp4",
    "720P" => "http://ex.shemalejapanhardcore.com/members/content/upload/uta/151224//720p/utaTBHC1_1_hdmp4.mp4",
  }

  def setup
    @video_html = open(File.join(HC_FIXTURES_ROOT, 'uta.video.html')).read
    @parser = Shja::Parser::HcMoviePage.new(@video_html)
  end

  def test_parse
    formats = @parser.parse
    assert_equal(FORMATS, formats)
  end

end
