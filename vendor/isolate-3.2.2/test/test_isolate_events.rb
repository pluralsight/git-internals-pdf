require "isolate/events"
require "isolate/test"

class TestIsolateEvents < Isolate::Test
  include Isolate::Events

  def setup
    Isolate::Events.watchers.clear
    super
  end

  def test_self_watch
    b = lambda {}
    Isolate::Events.watch String, :foo, &b
    assert_equal [b], Isolate::Events.watchers[[String, :foo]]
  end

  def test_fire
    count = 0

    Isolate::Events.watch self.class, :increment do
      count += 1
    end

    fire :increment
    assert_equal 1, count
  end

  def test_fire_block
    count = 0

    [:increment, :incremented].each do |name|
      Isolate::Events.watch self.class, name do
        count += 1
      end
    end

    fire :increment, :incremented do |x|
      assert_same self, x
    end

    assert_equal 2, count
  end
end
