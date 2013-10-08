#!/usr/bin/ruby

frequency = Hash.new
str = "TNVERI SMH EG ZSMRNPMUD: M SLRN PYMP VERRNVPT M ZSMRNP PE PYN TQR THNNZT EQP NXQMS MUNMT LR NXQMS PLKNT".downcase

str.each_char do |c|
  frequency[c] = frequency[c] == nil ? 1 : frequency[c] += 1
  case c
  when 'm'
    print 'a'
  when 'n'
    print 'e'
  when 'p'
    print 't'
  when 'e'
    print 'o'
  when 'y'
    print 'h'
  when 'l'
    print 'i'
  when 'r'
    print 's'
  else
    print c
  end
end
puts "\n\n"
puts frequency.inspect
puts "\n\n"
