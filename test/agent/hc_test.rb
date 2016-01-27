require 'test_helper'

class ShjaAgentHcTest < Minitest::Test

  def setup
    @agent = Shja::Agent::Hc.new
  end

  def test_fetch_actors
    letters = sequence('letters')
    ('A'..'F').each do |letter|
      @agent.expects(:fetch_index_page)
        .with(letter: letter)
        .returns([letter])
        .in_sequence(letters)
    end
    actors = @agent.fetch_actors(first_letter: 'A', last_letter: 'F')
    assert_equal(['A', 'B', 'C', 'D', 'E', 'F'], actors)
  end

  def test_fetch_actor_detail
    mock_actor = mock_actor('lisa')
    movies = [
      {'url' => 'a'}, {'url' => 'b'}, {'url' => 'c'}
    ].map { |e| Shja::Movie.new(e) }
    expected_id = '151224'
    expected_zip_url = 'http://ex.shemalejapanhardcore.com/members/content/upload/uta/151224/151224_1440highres.zip'
    expected_formats = { '720p' => 'http://720p.mp4' }

    @agent.expects(:_fetch_movie_list_from_actor_page)
          .with(mock_actor)
          .returns(movies)
    @agent.stubs(:_fetch_zip_url).returns(expected_zip_url)
    @agent.stubs(:_fetch_mp4_url).returns(expected_formats)

    actual_movies = @agent.fetch_actor_detail(mock_actor)
    assert_equal(3, actual_movies.size)
    actual_movies.each do |movie|
      assert_kind_of(Shja::Movie, movie)
      assert_equal(expected_zip_url, movie.zip)
      assert_equal(expected_formats, movie.formats)
      assert_equal(expected_id, movie.id)
    end
  end

  def test_fetch_index_page
    expected_index_url = "http://ex.shemalejapanhardcore.com/members/categories/models/1/name/A/"
    expects_urls = [0, 1]
    expects_actors = [{'url'=>'a'}, {'url'=>'b'}]

    parser = mock()
    parser.expects(:parse_pagination).returns(expects_urls)

    Shja::Parser::HcIndexPage.stubs(:new).returns(parser)
    urls = sequence('urls')
    @agent.expects(:_fetch_page).with(expected_index_url).returns('c').in_sequence(urls)
    @agent.expects(:_fetch_page).with(0).returns('c').in_sequence(urls)
    parser.expects(:parse_actors).returns(expects_actors).in_sequence(urls)
    @agent.expects(:_fetch_page).with(1).returns('c').in_sequence(urls)
    parser.expects(:parse_actors).returns(expects_actors).in_sequence(urls)

    actors = @agent.fetch_index_page
    expects_actors = (expects_actors + expects_actors).map { |a| Shja::Actor.new(a)  }
    assert_equal(expects_actors, actors)
  end

  # TODO: Add test if pagination size 0

  def test__fetch_page
    expected_url = 'URL'
    expected_content = 'CONTENT'
    page = mock()
    page.stubs(:content).returns(expected_content)
    @agent.stubs(:is_login).returns(true)

    @agent.agent.expects(:get).with(expected_url).returns(page)
    content = @agent._fetch_page(expected_url)
    assert_equal(expected_content, content)
  end

  def test__fetch_index_page
    page = 'PAGE_CONTENT'

    expected_url = "http://ex.shemalejapanhardcore.com/members/categories/models/11/name/Z/"
    @agent.expects(:_fetch_page).with(expected_url).returns(page)
    @agent._fetch_index_page(letter: 'Z', index: 10)
  end

  def test__fetch_movie_list_from_actor_page
    expected_page = 'PAGE_CONTENT'
    movies_hash = [{'url' => 'a'}, {'url' => 'b'}]
    mock_parser = mock('mock_parser')
    lisa = mock_actor('lisa')
    mock_parser.stubs(:parse).returns(movies_hash)

    @agent.expects(:_fetch_page).with(lisa.url).returns(expected_page)
    Shja::Parser::HcActorPage.expects(:new).with(expected_page).returns(mock_parser)

    movies = @agent._fetch_movie_list_from_actor_page(lisa)
    assert_equal(2, movies.size)
    movies.each_with_index do |movie, i|
      assert_kind_of(Shja::Movie, movie)
      assert_equal(lisa.id, movie.actor_id)
      assert_equal(movies_hash[i]['url'], movie.url)
    end
  end

  def test__fetch_zip_url
    expected_page = 'PAGE_CONTENT'
    expected_url  = 'http://zip_url'
    movie = mock_movie
    mock_parser = mock('mock_parser')
    mock_parser.stubs(:parse).returns(expected_url)

    @agent.expects(:_fetch_page).with(movie.photoset_url).returns(expected_page)
    Shja::Parser::HcZipPage.expects(:new).with(expected_page).returns(mock_parser)

    actual_url = @agent._fetch_zip_url(movie)
    assert_equal(actual_url, expected_url)
  end

  def test__fetch_mp4_url
    expected_page     = 'PAGE_CONTENT'
    expected_formats  = { '720p' => 'http://720p.mp4'}
    movie = mock_movie
    mock_parser = mock('mock_parser')
    mock_parser.stubs(:parse).returns(expected_formats)

    @agent.expects(:_fetch_page).with(movie.url).returns(expected_page)
    Shja::Parser::HcMoviePage.expects(:new).with(expected_page).returns(mock_parser)

    actual_formats = @agent._fetch_mp4_url(movie)
    assert_equal(actual_formats, expected_formats)
  end

end
