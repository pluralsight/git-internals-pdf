require "rubygems"
require "hoe"

$:.unshift "lib"
require "isolate/rake"

Hoe.plugins.delete :rubyforge
Hoe.plugin :isolate, :doofus, :git, :minitest

Hoe.spec "isolate" do
  developer "Ryan Davis",    "ryand-ruby@zenspider.com"
  developer "Eric Hodel",    "drbrain@segment7.net"
  developer "John Barnette", "code@jbarnette.com"

  require_rubygems_version ">= 1.8.2"

  self.extra_rdoc_files = Dir["*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"

  dependency "hoe-seattlerb", "~> 1.2", :development
  dependency "minitest",      "~> 2.1", :development
  dependency "hoe-doofus",    "~> 1.0", :development
  dependency "hoe-git",       "~> 1.3", :development
  dependency "ZenTest",       "~> 4.5", :development
end
