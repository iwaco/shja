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
    lisa = TEST_ACTORS['lisa']
    actor_manager.update(lisa)

    assert_equal(lisa, db.actors[0])
  end

  def test_save_twice_same_actor
    lisa = TEST_ACTORS['lisa']
    lisa2 = Shja::Actor.new(lisa.to_h)
    expected_changed_thumbnail = 'changed_url'
    lisa2['thumbnail'] = expected_changed_thumbnail
    actor_manager.update(lisa)
    actor_manager.update(lisa2)

    assert_equal(1, db.actors.size)
    assert_equal(expected_changed_thumbnail, db.actors[0]['thumbnail'])
  end

end
