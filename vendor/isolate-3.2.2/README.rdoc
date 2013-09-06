= Isolate

* http://github.com/jbarnette/isolate

== Description

Isolate is a very simple RubyGems sandbox. It provides a way to
express and automatically install your project's Gem dependencies.

== Wha?

When Isolate runs, it uses GEM_HOME, GEM_PATH, and a few other tricks
to separate your code from the system's RubyGems configuration,
leaving it free to run in blissful solitude.

Isolate is very, very, very stupid simple. For a much more
full-featured Gem bundler, check out Yehuda Katz and Carl Lerche's
Bundler[http://github.com/carlhuda/bundler]: It does a lot of fancy
AOT dependency resolution, supports non-gem (including git) resources,
and is probably a better fit for you.

== Requirements

RubyGems 1.8.2 or better, Ruby 1.8.7 or better.

== Getting Started

=== Rails 2

In <tt>config/preinitializer.rb</tt>:

    require "rubygems"
    require "isolate/now"

In <tt>Isolate</tt>:

    gem "rails", "2.3.5"
    gem "aasm",  "2.0.0"

    env :development, :test do
      gem "sqlite3-ruby", "1.2.5"
    end

    env :production do
      gem "memcached", "0.19.2"
    end

Try running <tt>rake environment</tt>. Before anything else happens,
Isolate will make sure you have copies of every gem you need (extend
the example above to cover all your dependencies). If they're already
installed on your system Isolate will use them, otherwise a private
copy will be installed under <tt>tmp/isolate</tt>.

=== Rails 3

In <tt>config/boot.rb</tt>:

    require "rubygems"
    require "isolate/now"

Construct your <tt>Isolate</tt> file as above. Be sure to remove any
references to <tt>Bundler.setup</tt> and <tt>Bundler.require</tt> from
<tt>config/boot.rb</tt> and <tt>config/application.rb</tt>.

Don't forget to require files from your isolated gems in the appropriate
places.  Unlike bundler isolate does not automatically require any files.

=== Sinatra, Rack, and Anything Else

There's nothing special about Rails, it's just an easy first
example. You can use Isolate with any library or framework by simply
putting an <tt>Isolate</tt> file in the root of your project and
requiring <tt>isolate/now</tt> as early as possible in the startup
process.

When you're starting up, Isolate tries to determine its environment by
looking at the <tt>ISOLATE_ENV</tt>, <tt>RACK_ENV</tt>, and
<tt>RAILS_ENV</tt> env vars. If none are set, it defaults to
<tt>development</tt>.

=== Library Development

If you're using Hoe[http://blog.zenspider.com/hoe] to manage your
library, you can use Isolate's Hoe plugin to automatically install
your lib's development, runtime, and test dependencies without
polluting your system RubyGems, and run your tests/specs in total
isolation.

Assuming you have a recent Hoe and Isolate is installed, it's as simple
as putting:

    Hoe.plugin :isolate

before the <tt>Hoe.spec</tt> call in your <tt>Rakefile</tt>.

If you're not using Hoe, you can use an <tt>Isolate.now!</tt> block at
the top of your Rakefile. See the RDoc for details.

== Rake

Isolate provides a few useful Rake tasks. If you're requiring
<tt>isolate/now</tt>, you'll get them automatically when you run
Rake. If not, you can include them by requiring <tt>isolate/rake</tt>.

=== isolate:env

This task shows you the current Isolate settings and gems.

    $ rake isolate:env

         path: tmp/isolate/ruby-1.8
          env: development
        files: Isolate

      cleanup? true
      enabled? true
      install? true
    multiruby? true
       system? true
      verbose? true

    [all environments]
    gem rails, = 2.3.5
    gem aasm, = 2.0.0

    [development, test]
    gem sqlite3-ruby, = 1.2.5

    [production]
    gem memcached, = 0.19.2

=== isolate:sh

This task allows you to run a subshell or a command in the isolated
environment, making any command-line tools available on your
<tt>PATH</tt>.

    # run a single command in an isolated subshell
    $ rake isolate:sh['gem list']

    # run a new isolated subshell
    $ rake isolate:sh

=== isolate:stale

This task lists gems that have a more recent released version than the
one you're using.

    $ rake isolate:stale
    aasm (2.0.0 < 2.1.5)

== Further Reading

<tt>require "isolate/now"</tt> is sugar for <tt>Isolate.now!</tt>,
which creates, configures, and activates a singleton version of
Isolate's sandbox. <tt>Isolate.now!</tt> takes a few useful options,
and lets you define an entire environment inline without using an
external file.

For detailed information on <tt>Isolate.now!</tt> and the rest of the
public API, please see the RDoc.

== Not Gonna Happen

* Autorequire. Unlike <tt>config.gems</tt> or other solutions, Isolate
  expects you to be a good little Rubyist and manually
  <tt>require</tt> the libraries you use.

* Support for Git or other SCMs. You're welcome to write an extension
  that supports 'em, but Isolate itself is focused on packaged,
  released gems.

== Installation

    $ gem install isolate

== Meta

RDoc::         http://rubydoc.info/gems/isolate/frames
Bugs::         http://github.com/jbarnette/isolate/issues
IRC::          #isolate on Freenode
Mailing List:: isolate@librelist.com

== License

Copyright 2009-2010 John Barnette, et al. (code@jbarnette.com)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
