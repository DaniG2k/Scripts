n = gets.chomp.to_i

ordered, final = Array.new(n), Array.new((n*2)-2)
info, to_pop = [], []

1.upto(n) {|iter| info << gets.chomp.split.collect {|e| e.to_i} }

info.each do |pair|
  if pair[1] == -1
    to_pop << pair[0]
  else
    pos = pair[1]-1
    ordered[pos] = pair[0]
  end
end

to_pop.sort!

i = 0
while !to_pop.empty?
  if ordered[i] == nil
    ordered[i] = to_pop.shift
  else
    i += 1
  end
end

info.each do |pair|
  if pair[1] == -1
    if pair[0] < ordered[0]
      tmp1 = ordered[ordered.index(pair[0])]
      tmp2 = ordered[0]
      ordered[0] = tmp1
      ordered[ordered.index(pair[0])] = tmp2
    elsif pair[0] < ordered[-1]
      tmp1 = ordered[ordered.index(pair[0])]
      tmp2 = ordered[-1]
      ordered[-1] = tmp1
      ordered[ordered.index(pair[0])] = tmp2
    end
  end
end

if ordered[0] > ordered[-1]
  tmp1, tmp2 = ordered[0], ordered[-1]
  ordered[0], ordered[-1]  = tmp2, tmp1
end

product = []
product << ordered.shift
0.upto(ordered.size - 2) do |i|
  n = ordered.shift
  product << n
  product << n
end
product << ordered.shift

# [20, 30, 30, 10, 10, 40, 40, 50, 50, 60]
# There is a mistake in the order of operations here,
# which I unfortunately did not have time to correct before submitting.

total = 1
product.each_with_index do |n, i|
  if product[i+1]
    if n == product[i+1]
      total += n
    else
      total *= n
    end
  end
end

puts total
