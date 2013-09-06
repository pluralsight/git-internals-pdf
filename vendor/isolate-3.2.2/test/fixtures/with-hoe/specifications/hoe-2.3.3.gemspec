# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hoe}
  s.version = "2.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Davis"]
  s.date = %q{2009-08-07}
  s.description = %q{Hoe is a rake/rubygems helper for project Rakefiles. It helps generate
rubygems and includes a dynamic plug-in system allowing for easy
extensibility. Hoe ships with plug-ins for all your usual project
tasks including rdoc generation, testing, packaging, and deployment.

Plug-ins Provided:

* Hoe::Clean
* Hoe::Debug
* Hoe::Deps
* Hoe::Flay
* Hoe::Flog
* Hoe::Inline
* Hoe::Package
* Hoe::Publish
* Hoe::RCov
* Hoe::Signing
* Hoe::Test

See class rdoc for help. Hint: ri Hoe}
  s.email = ["ryand-ruby@zenspider.com"]
  s.executables = ["sow"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/sow", "lib/hoe.rb", "lib/hoe/clean.rb", "lib/hoe/debug.rb", "lib/hoe/deps.rb", "lib/hoe/flay.rb", "lib/hoe/flog.rb", "lib/hoe/inline.rb", "lib/hoe/package.rb", "lib/hoe/publish.rb", "lib/hoe/rake.rb", "lib/hoe/rcov.rb", "lib/hoe/signing.rb", "lib/hoe/test.rb", "template/.autotest.erb", "template/History.txt.erb", "template/Manifest.txt.erb", "template/README.txt.erb", "template/Rakefile.erb", "template/bin/file_name.erb", "template/lib/file_name.rb.erb", "template/test/test_file_name.rb.erb", "test/test_hoe.rb"]
  s.homepage = %q{http://rubyforge.org/projects/seattlerb/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{seattlerb}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Hoe is a rake/rubygems helper for project Rakefiles}
  s.test_files = ["test/test_hoe.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubyforge>, [">= 1.0.4"])
      s.add_runtime_dependency(%q<rake>, [">= 0.8.7"])
    else
      s.add_dependency(%q<rubyforge>, [">= 1.0.4"])
      s.add_dependency(%q<rake>, [">= 0.8.7"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 1.0.4"])
    s.add_dependency(%q<rake>, [">= 0.8.7"])
  end
end
