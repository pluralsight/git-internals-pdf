#! /usr/local/bin/ruby
require 'rubygems'
require 'redcloth'

Dir.chdir('text') do
  puts `wc *`
end
 
test = File.new('text.textile', 'w')

Dir.glob('text/*').each do |filename|
  contents = File.read(filename)
  test.puts contents
  test.puts
end

test.close

html = File.new('text.html', 'w')

text = File.read('text.textile')
r = RedCloth.new(text)
html.puts r.to_html


