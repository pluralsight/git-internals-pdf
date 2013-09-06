require "isolate"

namespace :isolate do
  desc "Show current isolated environment."
  task :env do
    require "pathname"

    sandbox = Isolate.sandbox
    here    = Pathname Dir.pwd
    path    = Pathname(sandbox.path).relative_path_from here
    files   = sandbox.files.map { |f| Pathname(f) }

    puts
    puts "     path: #{path}"
    puts "      env: #{Isolate.env}"

    files.map! { |f| f.absolute? ? f.relative_path_from(here) : f }
    puts "    files: #{files.join ', '}"
    puts

    %w(cleanup? enabled? install? multiruby? system? verbose?).each do |flag|
      printf "%10s %s\n", flag, sandbox.send(flag)
    end

    grouped = Hash.new { |h, k| h[k] = [] }
    sandbox.entries.each { |e| grouped[e.environments] << e }

    puts

    grouped.keys.sort.each do |envs|
      title   = "all environments" if envs.empty?
      title ||= envs.join ", "

      puts "[#{title}]"

      grouped[envs].each do |e|
        gem = "gem #{e.name}, #{e.requirement}"
        gem << ", #{e.options.inspect}" unless e.options.empty?
        puts gem
      end

      puts
    end
  end

  desc "Run an isolated command or subshell."
  task :sh, [:command] do |t, args|
    exec args.command || ENV["SHELL"] || ENV["COMSPEC"]
  end

  desc "Which isolated gems have updates available?"
  task :stale do
    outdated = []
    sandbox  = Isolate.sandbox
    outdated = sandbox.entries.reject { |entry| entry.specification }

    Gem::Specification.outdated.each do |name|
      entry = sandbox.entries.find { |e| e.name == name }
      next unless entry
      outdated << entry
    end

    outdated.sort_by { |e| e.name }.each do |entry|
      local   = entry.specification ? entry.specification.version : "0"
      dep     = Gem::Dependency.new entry.name, ">= #{local}"
      remotes = Gem::SpecFetcher.fetcher.fetch dep
      remote  = remotes.last.first.version

      puts "#{entry.name} (#{local} < #{remote})"
    end
  end

  desc "Removes gems that have updates available"
  task :freshen do
    outdated = []
    sandbox  = Isolate.sandbox
    extra = sandbox.entries.reject { |entry| entry.specification }

    Gem::Specification.outdated.each do |name|
      entry = sandbox.entries.find { |e| e.name == name }
      next unless entry
      extra << entry.specification
    end

    sandbox.remove(*extra)
  end
end
