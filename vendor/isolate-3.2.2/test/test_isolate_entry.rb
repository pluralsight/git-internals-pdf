require "isolate/entry"
require "isolate/test"

class TestIsolateEntry < Isolate::Test
  def setup
    @sandbox = Object.new
    def @sandbox.environments; @e ||= [] end
    def @sandbox.path; "tmp/test" end

    super
  end

  def test_initialize
    @sandbox.environments.concat %w(foo bar)

    entry = e "baz", "> 1.0", "< 2.0", :quux => :corge

    assert_equal %w(foo bar), entry.environments
    assert_equal "baz", entry.name
    assert_equal Gem::Requirement.new("> 1.0", "< 2.0"), entry.requirement
    assert_equal :corge, entry.options[:quux]

    entry = e "plugh"

    assert_equal Gem::Requirement.default, entry.requirement
    assert_equal({}, entry.options)
  end

  def test_install_file
    file  = "test/fixtures/blort-0.0.gem"
    entry = e file
    entry.install

    assert_equal File.expand_path(file),
      Gem::DependencyInstaller.value.first.first
  end

  def test_matches?
    @sandbox.environments << "test"
    entry = e "hi"

    assert entry.matches?("test")
    assert !entry.matches?("double secret production")

    entry.environments.clear
    assert entry.matches?("double secret production")
  end

  def test_matches_spec?
    entry = e "hi", "1.1"

    assert entry.matches_spec?(spec("hi", "1.1"))
    assert !entry.matches_spec?(spec("bye", "1.1"))
    assert !entry.matches_spec?(spec("hi", "1.2"))
  end

  def test_update
    entry = e "hi", "1.1"

    assert_equal [], entry.environments

    @sandbox.environments.concat %w(corge corge plugh)
    entry.update

    assert_equal %w(corge plugh), entry.environments

    entry.update :foo => :bar
    entry.update :bar => :baz

    assert_equal({ :foo => :bar, :bar => :baz }, entry.options)

    entry.update :args => "--first"
    entry.update :args => "--second"
    assert_equal "--second", entry.options[:args]
  end

  def e *args
    Isolate::Entry.new @sandbox, *args
  end

  Spec = Struct.new :name, :version

  def spec name, version
    Spec.new name, Gem::Version.new(version)
  end
end
