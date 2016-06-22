require 'test_helper'

class ActorTest < Minitest::Test
  attr_reader :lisa, :uta
  attr_reader :mock_agent
  attr_reader :mock_parser

  def setup
    @lisa        = mock_actor('lisa')
    @uta         = mock_actor('uta')
    @mock_agent  = mock('agent')
    @mock_parser = mock('parser')
  end

  def teardown
    if uta.target_dir
      FileUtils.rm_r(uta.dir_path) if File.exist?(uta.dir_path)
    end
  end

  def test_download
    uta.target_dir = HC_TARGET_DIR
    mock_agent.expects(:_download).with(uta.thumbnail, uta.thumbnail_path)
    uta.download(mock_agent)
  end

  def test_download_with_exist
    lisa.target_dir = HC_TARGET_DIR
    mock_agent.expects(:_download).never
    lisa.download(mock_agent)
  end

  def test_download_not_set_target_dir
    assert_raises do
      lisa.download(mock_agent)
    end
  end

  def test_fetch_movies
    movies = [
      {'url' => 'a', 'photoset_url' => 'aaa.html'},
      {'url' => 'b', 'photoset_url' => 'bbb.html'},
      {'url' => 'c', 'photoset_url' => 'ccc.html'}
    ].map { |e| Shja::Movie::Hc.new(e) }
    expected_ids = [
      'aaa', 'bbb', 'ccc'
    ]
    expected_zip_url = 'http://ex.shemalejapanhardcore.com/members/content/upload/uta/151224/151224_1440highres.zip'
    expected_formats = { '720p' => 'http://720p.mp4' }

    lisa.expects(:_fetch_movie_list_from_actor_page)
        .with(mock_agent)
        .returns(movies)
    lisa.stubs(:_fetch_zip_url).returns(expected_zip_url)
    lisa.stubs(:_fetch_mp4_url).returns(expected_formats)

    actual_movies = lisa.fetch_movies(mock_agent)
    assert_equal(3, actual_movies.size)
    actual_movies.each_with_index do |movie, i|
      assert_kind_of(Shja::Movie::Hc, movie)
      assert_equal(expected_zip_url, movie.zip)
      assert_equal(expected_formats, movie.formats)
      assert_equal(expected_ids[i], movie.id)
    end
  end

  def test__fetch_movie_list_from_actor_page
    expected_page = 'PAGE_CONTENT'
    movies_hash = [{'url' => 'a'}, {'url' => 'b'}]
    mock_parser.stubs(:parse_movies).returns(movies_hash)

    mock_agent.expects(:_fetch_page).with(lisa.url).returns(expected_page)
    Shja::Parser::HcActorPage.expects(:new).with(expected_page).returns(mock_parser)

    movies = lisa._fetch_movie_list_from_actor_page(mock_agent)
    assert_equal(2, movies.size)
    movies.each_with_index do |movie, i|
      assert_kind_of(Shja::Movie::Hc, movie)
      assert_equal(lisa.id, movie.actor_id)
      assert_equal(movies_hash[i]['url'], movie.url)
    end
  end

  def test__fetch_zip_url
    expected_page = 'PAGE_CONTENT'
    expected_url  = 'http://zip_url'
    movie = mock_movie
    mock_parser.stubs(:parse_zip_url).returns(expected_url)

    mock_agent.expects(:_fetch_page).with(movie.photoset_url).returns(expected_page)
    Shja::Parser::HcZipPage.expects(:new).with(expected_page).returns(mock_parser)

    actual_url = lisa._fetch_zip_url(mock_agent, movie)
    assert_equal(actual_url, expected_url)
  end

  def test__fetch_mp4_url
    expected_page     = 'PAGE_CONTENT'
    expected_formats  = { '720p' => 'http://720p.mp4'}
    movie = mock_movie
    mock_parser.stubs(:parse).returns(expected_formats)

    mock_agent.expects(:_fetch_page).with(movie.url).returns(expected_page)
    Shja::Parser::HcMoviePage.expects(:new).with(expected_page).returns(mock_parser)

    actual_formats = lisa._fetch_mp4_url(mock_agent, movie)
    assert_equal(actual_formats, expected_formats)
  end

end
