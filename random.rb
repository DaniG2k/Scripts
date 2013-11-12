#!/usr/bin/ruby
#
# (Semi)-random string generator
# random.rb len lucky
# Length defaults to 10
# Lucky defaults to true (include '9', exclude '4')
#

def pwd_gen
	pwd = Array.new
  rc = ->{ [*'/'..'~'].sample }
	ARGV[0] ? ARGV[0].to_i.times{ pwd << rc.call } : 18.times { pwd << rc.call }
	pwd.join
end

if !ARGV[1] or %w(lucky true t).include?(ARGV[1].downcase)
	lucky = true
elsif ARGV[1] and %w(unlucky false f).include?(ARGV[1].downcase)
	lucky = false
end

if lucky
	pwd = pwd_gen until pwd.include?('9') and !pwd.include?('4')
else
	pwd = pwd_gen
end

puts "\nPassword: #{pwd}"
puts "Length: #{pwd.length}"
puts "\n"
