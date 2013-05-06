grid = [[nil, nil, 8], [6, nil, 1], [nil, 4, nil],
        [nil, 1, nil], [nil, 9, nil], [nil, 3, 7],
        [nil, nil, 9], [3, 2, nil], [nil, nil, 5],
        [nil, 3, 5], [nil, nil, 2], [nil, nil, 4],
        [nil, nil, 8], [6, 5, nil], [nil, nil, 1],
        [2, nil, nil], [8, nil, nil], [7, 5, nil],
        [5, nil, nil], [nil, 9, 7], [1, nil, nil],
        [3, 4, nil], [nil, 8, nil], [nil, 6, nil],
        [nil, 8, nil], [5, nil, 6], [9, nil, nil]]

def find_unknowns(region)
  arr = Array.new
  region.each do |row|
    row.each do |val|
      if not val.nil?
        arr << val
      end
    end
  end
  (1..9).to_a - arr
end

def get_row(grid, region, rownum)
  if region < 3
    srow = grid[0..8]
  elsif region > 2 and region < 6
    srow = grid[9..17]
  else
    srow = grid[18..26]
  end

  row = []
  if rownum == 0
    [0, 3, 6].each { |n| row << srow[n] }
  elsif rownum == 1
    [1, 4, 7].each { |n| row << srow[n] }
  else
    [2, 5, 8].each { |n| row << srow[n] }
  end
  row
end

def get_col(grid, region, colnum)
  if [0,3,6].include? region
    scol = grid[0..2] + grid[9..11] + grid[18..20]
  elsif [1,4,7].include? region
    scol = grid[3..5] + grid[12..14] + grid[21..23]
  else
    scol = grid[6..8] + grid[15..17] + grid[24..26]
  end

  col = []
  scol.each { |row| col << row[colnum] }
  col
end

def get_all_rows(grid)
  all_rows = []
  [0, 3, 6].each do |region|
    (0..2).each do |row|
      all_rows << get_row(grid, region, row)
    end
  end
  all_rows
end

def get_all_cols(grid)
  all_cols = []
  (0..2).each do |region|
    (0..2).each do |col|
      all_cols << get_col(grid, region, col)
    end
  end
  all_cols
end
