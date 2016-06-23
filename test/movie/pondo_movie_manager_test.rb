require 'test_helper'

class PondoMovieManageTest < ShjaPondoTest
  attr_reader :movie_manager

  def setup
    super
    @movie_manager = Shja::MovieManager::Pondo.new(context)
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
end
