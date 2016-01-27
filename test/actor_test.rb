require 'test_helper'

class ActorManageTest < ShjaDBTest
  attr_reader :actor_manager

  def setup
    super
    @actor_manager = Shja::ActorManager.new(db)
  end

  def test_db
    assert_kind_of(Shja::Db, actor_manager.db)
  end

  def test_save
    lisa = mock_actor('lisa')
    actor_manager.update(lisa)

    assert_equal(lisa, db.actors[0])
  end

  def test_save_twice_same_actor
    lisa = mock_actor('lisa')
    lisa2 = mock_actor('lisa')
    expected_changed_thumbnail = 'changed_url'
    lisa2['thumbnail'] = expected_changed_thumbnail
    actor_manager.update(lisa)
    actor_manager.update(lisa2)

    assert_equal(1, db.actors.size)
    assert_equal(expected_changed_thumbnail, db.actors[0]['thumbnail'])
  end

  def test_find
    actors = [mock_actor('lisa'), mock_actor('serina'), mock_actor('chuling')]
    actors.each do |actor|
      actor_manager.update(actor)
    end

    assert_equal(mock_actor('serina'), actor_manager.find('serina'))
  end

  def test_find_non_existance
    actors = [mock_actor('lisa'), mock_actor('serina'), mock_actor('chuling')]
    actors.each do |actor|
      actor_manager.update(actor)
    end

    assert_raises { actor_manager.find('not_found') }
  end

end
