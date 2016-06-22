require 'test_helper'

class MovieTest < Minitest::Test
  attr_reader :movie
  attr_reader :lisa
  attr_reader :mock_agent
  attr_reader :mock_parser

  attr_reader :uta_movie
  attr_reader :uta

  def setup
    @lisa = mock_hc_actor('lisa')
    @lisa.target_dir = HC_TARGET_DIR
    @movie = mock_hc_movie('lisa_movie')
    @movie.actor = @lisa
    @mock_agent  = mock('agent')
    @mock_parser = mock('parser')

    @uta = mock_hc_actor('uta')
    @uta.target_dir = File.join(HC_FIXTURES_ROOT, 'exists')
    @uta_movie = mock_hc_movie('uta_movie')
    @uta_movie.actor = @uta
  end

  def teardown
    FileUtils.rm_r(movie.dir_path) if File.exist?(movie.dir_path)
  end

  def test_set_actor
    actor = mock_hc_actor('serina')
    movie = mock_hc_movie('lisa_movie')

    movie.actor = actor
    assert_equal(actor.id, movie.actor_id)
    assert_equal(actor, movie.actor)
  end

  def test_download_thumbnail
    mock_agent.expects(:download).with(movie.thumbnail, movie.thumbnail_path)
    movie.download_thumbnail(mock_agent)
  end

  def test_download_photoset
    expect_content = 'mock page content'
    expect_pictures = 'mock pictures url'
    expect_urls = ['http://second', 'http://third']

    Shja::Parser::HcZipPage.expects(:new)
                           .with(expect_content)
                           .returns(mock_parser).times(3)
    seq = sequence('urls')
    mock_agent.expects(:_fetch_page)
              .with(movie.photoset_url)
              .returns(expect_content)
              .in_sequence(seq)
    mock_agent.expects(:_fetch_page)
              .with(expect_urls[0])
              .returns(expect_content)
              .in_sequence(seq)
    mock_agent.expects(:_fetch_page)
              .with(expect_urls[1])
              .returns(expect_content)
              .in_sequence(seq)
    mock_parser.expects(:parse_pictures)
               .returns({pictures: expect_pictures, pages: expect_urls})
               .times(3)
    movie.expects(:_download_pictures)
         .with(mock_agent, expect_pictures)
         .times(3)

    movie.download_photoset(mock_agent)
  end

  def test_picture_path
    basename = "photoset_001.jpg"
    photoset_url = "http://photoset/#{basename}"
    photoset_dir_path = "/dir/photoset"
    expect_path = "#{photoset_dir_path}/#{basename}"
    movie.stubs(:photoset_dir_path).returns(photoset_dir_path)

    actual_path = movie.picture_path(photoset_url)
    assert_equal(expect_path, actual_path)
  end

  def test__download_pictures
    picture_url = 'http://photoset.jpg'
    picture_path = '/photoset.jpg'

    movie.stubs(:picture_path).with(picture_url).returns(picture_path)
    movie.expects(:_download).with(mock_agent, picture_url, picture_path)

    movie._download_pictures(mock_agent, [picture_url])
  end

  def test_pictures_metadata
    actual_metadata = uta_movie.pictures_metadata
    assert_equal(1, actual_metadata.size)
    assert_equal({"name" => 'img.jpg', 'w' => 256, 'h' => 144}, actual_metadata[0])
  end
end
