#!/usr/bin/ruby
class Vector
  attr_accessor :points

  def initialize(points)
    @points = points
  end

  def size
    @points.size
  end

  def +(vec2)
    check_sizes vec2
    Vector.new @points.each_with_index.map {|_, i| (@points[i] + vec2.points[i])}
  end

  def -(vec2)
    check_sizes vec2
    Vector.new @points.each_with_index.map {|_, i| (@points[i] - vec2.points[i])}
  end

  def *(vec2)
    Vector.new(vec2.points.map {|n| (@points * n)})
  end

  def /(vec2)
    Vector.new(vec2.points.map {|n| (@points / n)})
  end

  def magnitude
    sum_of_sqares = @points.map {|n| n**2}.reduce(:+)
    Math.sqrt(sum_of_sqares)
  end

  def normalize
    Vector.new(1 / magnitude) * self
  end

  def dot_product(vec2)
    check_sizes vec2
    @points.each_with_index.map {|n, i| n * vec2.points[i]}.reduce(:+)
  end

  %w(radians degrees).each do |type|
    define_method("angle_in_#{type}") do |vec2|
      angle = Math.acos(dot_product(vec2) / (magnitude * vec2.magnitude))
      if type == 'degrees'
        angle * 180 / Math::PI
      else
        angle
      end
    end
  end

  # def parallel?(vec2)
  #   normalize.points == vec2.normalize.points
  # end

  def orthogonal?(vec2)
    dot_product(vec2).zero?
  end

  private
  def check_sizes(vec2)
    raise ArgumentError, 'Vectors are of unequal size.' if size != vec2.size
  end
end
