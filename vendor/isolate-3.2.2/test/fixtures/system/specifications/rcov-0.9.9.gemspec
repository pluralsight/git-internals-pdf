# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rcov}
  s.version = "0.9.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Relevance}, %q{Chad Humphries (spicycode)}, %q{Aaron Bedra (abedra)}, %q{Jay McGaffigan(hooligan495)}, %q{Mauricio Fernandez}]
  s.cert_chain = nil
  s.date = %q{2009-12-28}
  s.description = %q{rcov is a code coverage tool for Ruby. It is commonly used for viewing overall test unit coverage of target code.  It features fast execution (20-300 times faster than previous tools), multiple analysis modes, XHTML and several kinds of text reports, easy automation with Rake via a RcovTask, fairly accurate coverage information through code linkage inference using simple heuristics, colorblind-friendliness...}
  s.email = %q{opensource@thinkrelevance.com}
  s.executables = [%q{rcov}]
  s.extensions = [%q{ext/rcovrt/extconf.rb}]
  s.files = [%q{bin/rcov}, %q{ext/rcovrt/extconf.rb}]
  s.homepage = %q{http://github.com/relevance/rcov}
  s.rdoc_options = [%q{--title}, %q{rcov code coverage tool}]
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.8.2}
  s.summary = %q{Code coverage analysis tool for Ruby}

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
