nk = gets.chomp.split
n, k = nk[0].to_i, nk[1].to_i
balls, moves = [1,2,3,4,5,6,7,8], []

1.upto(n) do |move|
  moves << gets.chomp.split.collect{|n| n.to_i}
end

1.upto(k) do |i|
  moves.each do |move|
    pos1, pos2 = move[0]-1, move[1]-1
    tmp1, tmp2 = balls[pos1], balls[pos2]
    balls[pos1], balls[pos2] = tmp2, tmp1
  end
end

puts balls.join ' '
