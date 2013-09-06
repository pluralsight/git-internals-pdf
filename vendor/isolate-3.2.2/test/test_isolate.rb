require "isolate/test"

require "isolate"

class TestIsolate < Isolate::Test
  WITH_HOE = "test/fixtures/with-hoe"

  def teardown
    Isolate.sandbox.disable if Isolate.sandbox
    super
  end

  def test_self_env
    assert_equal "development", Isolate.env

    ENV["RAILS_ENV"] = "foo"

    assert_equal "foo", Isolate.env

    ENV["RAILS_ENV"] = nil
    ENV["RACK_ENV"]  = "bar"

    assert_equal "bar", Isolate.env

    ENV["RACK_ENV"]    = nil
    ENV["ISOLATE_ENV"] = "baz"

    assert_equal "baz", Isolate.env
  end

  def test_self_now!
    assert_nil Isolate.sandbox

    Isolate.now!(:path      => WITH_HOE,
                 :multiruby => false,
                 :system    => false,
                 :verbose   => false) do
      gem "hoe"
    end

    refute_nil Isolate.sandbox
    assert_equal File.expand_path(WITH_HOE), Isolate.sandbox.path
    assert_equal "hoe", Isolate.sandbox.entries.first.name
  end
end
