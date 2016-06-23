require 'test_helper'

class PondoMovieManageTest < ShjaPondoTest
  attr_reader :movie_manager

  def setup
    super
    @movie_manager = Shja::MovieManager::Pondo.new(context)
    Shja::Movie::Pondo.any_instance.stubs(:download_metadata)
  end

  def test_download_index
    open(File.join(PONDO_FAKE_RESPONSE_DIR, 'list_newest_00.json')) do |io|
      context.agent.expects(:fetch_page).returns(io.read).once
    end
    movie_manager.expects(:update).with do |actual|
      actual.kind_of?(Shja::Movie::Pondo)
    end

    movie_manager.download_index
  end

  def test_download_index_twice
    open(File.join(PONDO_FAKE_RESPONSE_DIR, 'list_newest_01.json')) do |io|
      context.agent.expects(:fetch_page).returns(io.read).once
    end
    movie_manager.expects(:update).with do |actual|
      actual.kind_of?(Shja::Movie::Pondo)
    end.at_least(2)

    movie_manager.download_index
  end

  def test_update
    movie_manager.update(mock_pondo_movie('mari_movie'))

    assert_equal(1, db.movies.size)
  end

  def test_update_same_movie
    movie_manager.update(mock_pondo_movie('mari_movie'))
    movie_manager.update(mock_pondo_movie('mari_movie'))

    assert_equal(1, db.movies.size)
  end

  def test_update_two_movie
    movie_manager.update(mock_pondo_movie('mari_movie'))
    movie_manager.update(mock_pondo_movie('ami_movie'))

    assert_equal(2, db.movies.size)
  end

  def test_all
    movie_manager.update(mock_pondo_movie('mari_movie'))
    movie_manager.update(mock_pondo_movie('ami_movie'))

    movie_manager.all do |movie|
      assert_kind_of(Shja::Movie::Pondo, movie)
    end
  end

  def test_find
    movie_manager.update(mock_pondo_movie('mari_movie'))
    movie_manager.update(mock_pondo_movie('ami_movie'))

    assert_equal(3440, movie_manager.find('061516_317')['MetaMovieID'])
  end
end
