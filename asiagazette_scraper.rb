#!/usr/bin/ruby
require 'mechanize'

urls = File.open 'asiagazette_urls.txt'
urls.each do |url|
  article = Hash.new
  page = Mechanize.new.get(url)
  article['title'] = page.search("//h1").text
  puts line
end
