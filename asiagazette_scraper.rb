#!/usr/bin/ruby
require 'mechanize'

urls = File.open 'asiagazette_urls.txt'
urls.each do |url|
  article = Hash.new
  page = Mechanize.new.get(url)
  article['title'] = page.search("//h1").text
  submitted = page.search("span.submitted").text
  puts line
end

def parse_submit(s)
  match = s.scan(/by (.*)? on .*, (.*$)?/).first
  name = match[0]
  date = match[1]
end
