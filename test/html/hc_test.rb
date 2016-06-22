require 'test_helper'
require 'json'

class HtmlTest < Minitest::Test
  attr_reader :movie_manager
  attr_reader :html

  def setup
    @target_dir    = File.join(HC_FIXTURES_ROOT, 'exists')
    @db            = Shja::Db::Hc.get(@target_dir)
    @actor_manager = Shja::ActorManager::Hc.new(@db, @target_dir)
    @movie_manager = Shja::MovieManager::Hc.new(@db, @actor_manager)

    @html = Shja::Html::Hc.new(movies: movie_manager)
  end

  def test_movies_js_list
    html.expects(:generate_detail_js).times(4)
    actual_list = html.movies_js_list
    assert_equal(4, actual_list.size)
    actual_list.each do |js|
      assert_equal(true, js.has_key?('id'))
      assert_equal(true, js.has_key?('dir'))
      assert_equal('thumbnail.jpg', js['jpg'])
      assert_equal('photoset', js['detail'])
      assert_equal(true, js.has_key?('title'))
      assert_equal(true, js.has_key?('url'))
      assert_equal(true, js.has_key?('date'))
      assert_equal(true, js.has_key?('formats'))
    end
    assert_equal("720p.mp4", actual_list[0]['formats']['720p'])
    assert_nil(actual_list[0]['formats']['480p'])
    assert_nil(actual_list[1]['formats']['720p'])
  end
end
