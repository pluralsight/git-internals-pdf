require "isolate"
require "minitest/autorun"

ENV.delete "RUBYOPT" # Rakefile uses isolate, so we don't want this

module Isolate
  Sandbox::DEFAULT_PATH.replace "tmp/test" # change isolate dir for testing

  class Test < MiniTest::Unit::TestCase
    def setup
      Isolate.refresh

      @env = ENV.to_hash
      @lp  = $LOAD_PATH.dup
      @lf  = $LOADED_FEATURES.dup
    end

    def teardown
      Gem::DependencyInstaller.reset_value
      Gem::Uninstaller.reset_value

      ENV.replace @env
      $LOAD_PATH.replace @lp
      $LOADED_FEATURES.replace @lf

      FileUtils.rm_rf "tmp/test"
    end
  end
end

module BrutalStub
  @@value = []
  def value; @@value end
  def reset_value; value.clear end
end

class Gem::DependencyInstaller
  extend BrutalStub

  alias old_install install
  def install name, requirement
    self.class.value << [name, requirement]
  end
end

class Gem::Uninstaller
  extend BrutalStub

  attr_reader :gem, :version
  alias old_uninstall uninstall

  def uninstall
    self.class.value << [self.gem,
                         self.version.to_s,
                         self.gem_home.sub(Dir.pwd + "/", '')]
  end
end
