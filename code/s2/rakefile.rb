spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "simplegit"
<<<<<<< HEAD:Rakefile
    s.version   =   "0.1.2"
=======
    s.version   =   "0.2.0"
>>>>>>> versioning:Rakefile
    s.author    =   "Scott Chacon"
    s.email     =   "schacon@gmail.com"
    s.summary   =   "A simple gem for using Git in Ruby code."
    s.files     =   FileList['lib/**/*'].to_a
    s.require_path  =   "lib"
end