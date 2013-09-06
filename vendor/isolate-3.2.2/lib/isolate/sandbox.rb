require "fileutils"
require "isolate/entry"
require "isolate/events"
require "rbconfig"
require "rubygems/defaults"
require "rubygems/uninstaller"
require "rubygems/deprecate"

module Isolate

  # An isolated environment. This class exposes lifecycle events for
  # extension, see Isolate::Events for more information.

  class Sandbox
    include Events

    DEFAULT_PATH = "tmp/isolate" # :nodoc:

    attr_reader :entries # :nodoc:
    attr_reader :environments # :nodoc:
    attr_reader :files # :nodoc:

    # Create a new Isolate::Sandbox instance. See Isolate.now! for the
    # most common use of the API. You probably don't want to use this
    # constructor directly.  Fires <tt>:initializing</tt> and
    # <tt>:initialized</tt>.

    def initialize options = {}, &block
      @enabled      = false
      @entries      = []
      @environments = []
      @files        = []
      @options      = options

      fire :initializing

      user = File.expand_path "~/.isolate/user.rb"
      load user if File.exist? user

      file, local = nil

      unless FalseClass === options[:file]
        file  = options[:file] || Dir["{Isolate,config/isolate.rb}"].first
        local = "#{file}.local" if file
      end

      load file if file

      if block_given?
        /\@(.+?):\d+/ =~ block.to_s
        files << ($1 || "inline block")
        instance_eval(&block)
      end

      load local if local && File.exist?(local)
      fire :initialized
    end

    # Activate this set of isolated entries, respecting an optional
    # +environment+. Points RubyGems to a separate repository, messes
    # with paths, auto-installs gems (if necessary), activates
    # everything, and removes any superfluous gem (again, if
    # necessary). If +environment+ isn't specified, +ISOLATE_ENV+,
    # +RAILS_ENV+, and +RACK_ENV+ are checked before falling back to
    # <tt>"development"</tt>. Fires <tt>:activating</tt> and
    # <tt>:activated</tt>.

    def activate environment = nil
      enable unless enabled?
      fire :activating

      env = (environment || Isolate.env).to_s

      install env if install?

      entries.each do |e|
        e.activate if e.matches? env
      end

      cleanup if cleanup?
      fire :activated

      self
    end

    def cleanup # :nodoc:
      fire :cleaning

      gem_dir = Gem.dir

      global, local = Gem::Specification.partition { |s| s.base_dir != gem_dir }
      legit = legitimize!
      extra = (local - legit) + (local & global)

      self.remove(*extra)

      fire :cleaned
    end

    def cleanup?
      install? and @options.fetch(:cleanup, true)
    end

    def disable &block
      return self if not enabled?
      fire :disabling

      ENV.replace @old_env
      $LOAD_PATH.replace @old_load_path

      @enabled = false

      Isolate.refresh
      fire :disabled

      begin; return yield ensure enable end if block_given?

      self
    end

    def enable # :nodoc:
      return self if enabled?
      fire :enabling

      @old_env       = ENV.to_hash
      @old_load_path = $LOAD_PATH.dup

      path = self.path

      FileUtils.mkdir_p path
      ENV["GEM_HOME"] = path

      unless system?
        isolate_lib = File.expand_path "../..", __FILE__

        # manually deactivate pre-isolate gems... is this just for 1.9.1?
        $LOAD_PATH.reject! do |p|
          p != isolate_lib && Gem.path.any? { |gp| p.include?(gp) }
        end

        # HACK: Gotta keep isolate explicitly in the LOAD_PATH in
        # subshells, and the only way I can think of to do that is by
        # abusing RUBYOPT.

        unless ENV["RUBYOPT"] =~ /\s+-I\s*#{Regexp.escape isolate_lib}\b/
          ENV["RUBYOPT"] = "#{ENV['RUBYOPT']} -I#{isolate_lib}"
        end

        ENV["GEM_PATH"] = path
      end

      bin = File.join path, "bin"

      unless ENV["PATH"].split(File::PATH_SEPARATOR).include? bin
        ENV["PATH"] = [bin, ENV["PATH"]].join File::PATH_SEPARATOR
      end

      ENV["ISOLATED"] = path

      if system? then
        Gem.path.unshift path # HACK: this is just wrong!
        Gem.path.uniq!        # HACK: needed for the previous line :(
      end
      Isolate.refresh

      @enabled = true
      fire :enabled

      self
    end

    def enabled?
      @enabled
    end

    # Restricts +gem+ calls inside +block+ to a set of +environments+.

    def environment *environments, &block
      old = @environments
      @environments = @environments.dup.concat environments.map { |e| e.to_s }

      instance_eval(&block)
    ensure
      @environments = old
    end

    alias_method :env, :environment

    # Express a gem dependency. Works pretty much like RubyGems' +gem+
    # method, but respects +environment+ and doesn't activate 'til
    # later.

    def gem name, *requirements
      entry = entries.find { |e| e.name == name }
      return entry.update(*requirements) if entry

      entries << entry = Entry.new(self, name, *requirements)
      entry
    end

    # A source index representing only isolated gems.

    def index
      @index ||= Gem::SourceIndex.from_gems_in File.join(path, "specifications")
    end

    def install environment # :nodoc:
      fire :installing

      installable = entries.select do |e|
        !e.specification && e.matches?(environment)
      end

      unless installable.empty?
        padding = Math.log10(installable.size).to_i + 1
        format  = "[%0#{padding}d/%s] Isolating %s (%s)."

        installable.each_with_index do |entry, i|
          log format % [i + 1, installable.size, entry.name, entry.requirement]
          entry.install
        end

        Gem::Specification.reset
      end

      fire :installed

      self
    end

    def install? # :nodoc:
      @options.fetch :install, true
    end

    def load file # :nodoc:
      files << file
      instance_eval IO.read(file), file, 1
    end

    def log s # :nodoc:
      $stderr.puts s if verbose?
    end

    def multiruby?
      @options.fetch :multiruby, true
    end

    def options options = nil
      @options.merge! options if options
      @options
    end

    def path
      base = @options.fetch :path, DEFAULT_PATH

      unless @options.key?(:multiruby) && @options[:multiruby] == false
        suffix = "#{Gem.ruby_engine}-#{RbConfig::CONFIG['ruby_version']}"
        base   = File.join(base, suffix) unless base =~ /#{suffix}/
      end

      File.expand_path base
    end

    def remove(*extra)
      unless extra.empty?
        padding = Math.log10(extra.size).to_i + 1
        format  = "[%0#{padding}d/%s] Nuking %s."

        extra.each_with_index do |e, i|
          log format % [i + 1, extra.size, e.full_name]

          Gem::DefaultUserInteraction.use_ui Gem::SilentUI.new do
            uninstaller =
              Gem::Uninstaller.new(e.name,
                                   :version     => e.version,
                                   :ignore      => true,
                                   :executables => true,
                                   :install_dir => e.base_dir)
            uninstaller.uninstall
          end
        end
      end
    end

    def system?
      @options.fetch :system, true
    end

    def verbose?
      @options.fetch :verbose, true
    end

    private

    # Returns a list of Gem::Specification instances that 1. exist in
    # the isolated gem path, and 2. are allowed to be there. Used in
    # cleanup. It's only an external method 'cause recursion is
    # easier.

    def legitimize! deps = entries
      specs = []

      deps.flatten.each do |dep|
        spec = case dep
               when Gem::Dependency then
                 begin
                   dep.to_spec
                 rescue Gem::LoadError
                   nil
                 end
               when Isolate::Entry then
                 dep.specification
               else
                 raise "unknown dep: #{dep.inspect}"
               end

        if spec then
          specs.concat legitimize!(spec.runtime_dependencies)
          specs << spec
        end
      end

      specs.uniq
    end

    dep_module = defined?(Gem::Deprecate) ? Gem::Deprecate : Deprecate
    extend dep_module
    deprecate :index, :none, 2011, 11
  end
end
