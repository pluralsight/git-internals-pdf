require "rubygems"
require "isolate"

class Hoe # :nodoc:

  # This module is a Hoe plugin. You can set its attributes in your
  # Rakefile's Hoe spec, like this:
  #
  #    Hoe.plugin :isolate
  #
  #    Hoe.spec "myproj" do
  #      self.isolate_dir = "tmp/isolated"
  #    end
  #
  # NOTE! The Isolate plugin is a little bit special: It messes with
  # the plugin ordering to make sure that it comes before everything
  # else.

  module Isolate

    # Where should Isolate, um, isolate? [default: <tt>"tmp/isolate"</tt>]
    # FIX: consider removing this and allowing +isolate_options+ instead.

    attr_accessor :isolate_dir

    def initialize_isolate
      # Tee hee! Move ourselves to the front to beat out :test.
      Hoe.plugins.unshift Hoe.plugins.delete(:isolate)

      self.isolate_dir ||= "tmp/isolate"

      ::Isolate.sandbox ||= ::Isolate::Sandbox.new

      ::Isolate.sandbox.entries.each do |entry|
        dep = [entry.name, *entry.requirement.as_list]

        if entry.environments.include? "development"
          extra_dev_deps << dep
        elsif entry.environments.empty?
          extra_deps << dep
        end
      end
    end

    def define_isolate_tasks
      sandbox = ::Isolate.sandbox

      # reset, now that they've had a chance to change it
      sandbox.options :path => isolate_dir, :system => false

      task :isolate do
        self.extra_deps.each do |name, version|
          sandbox.gem name, *Array(version)
        end

        self.extra_dev_deps.each do |name, version|
          sandbox.env "development" do
            sandbox.gem name, *Array(version)
          end
        end

        sandbox.activate
      end

      task :test => :isolate
    end
  end
end
