require 'test_helper'

class CaribMovieTest < Minitest::Test
  attr_reader :fixtures
  attr_reader :context
  attr_reader :target_dir

  def setup
    @fixtures = {}
    @target_dir ||= File.join(TMP_ROOT, SecureRandom.hex(8))
    @context    = Hashie::Mash.new(
      target_dir: @target_dir,
    )
    db_fixture_path = File.join(FIXTURES_ROOT, 'carib', 'db.yml')
    open(db_fixture_path) do |io|
      YAML.load(io.read).each do |movie|
        movie = Shja::Db::Carib::Movie.new(movie)
        @fixtures[movie.key] = Shja::Movie::Carib.new(@context, movie)
      end
    end
  end

  def movie
    fixtures['movie/2017-07-18/071817-463']
  end

  def test_dir_url
    assert_equal 'movies/2017-07/071817-463', movie.dir_url
  end

  def test_remote_thumbnail_url
    assert_equal 'https://tarimages.caribbeancom.com/images/flash256x144/114251.jpg', movie.remote_thumbnail_url
  end

  def test_remote_zip_url
    assert_equal 'http://www.caribbeancom.com/moviepages/071817-463/images/gallery.zip', movie.remote_zip_url
  end

  def test_photoset_dir_url
    assert_equal 'movies/2017-07/071817-463', movie.photoset_dir_url
  end

  def test_movie_url
    assert_equal 'movies/2017-07/071817-463-1080p.mp4', movie.movie_url('1080p')
  end

  def test_to_path
    assert_equal "#{target_dir}/movies/2017-07/071817-463", movie.to_path(:dir_url)
  end

end
