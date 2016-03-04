#!/usr/bin/ruby
module Udacity
  class Vector
    attr_accessor :points

    def initialize(points)
      @points = points
    end

    def size
      @points.size
    end

    def +(vec2)
      check_size vec2
      Vector.new @points.each_with_index.map {|_, i| (@points[i] + vec2.points[i])}
    end

    def -(vec2)
      check_size vec2
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
      check_size vec2
      @points.each_with_index.map {|n, i| n * vec2.points[i]}.reduce(:+)
    end

    def cross_product(vec2)
      # More than 2 points are required for unpacking.
      if size == 2 && vec2.size == 2
        @points << 0
        vec2.points << 0
      end
      a1, a2, a3 = @points[0], @points[1], @points[2]
      b1, b2, b3 = vec2.points[0], vec2.points[1], vec2.points[2]
      Vector.new [
        ((a2*b3) - (a3*b2)),
        ((a3*b1) - (a1*b3)),
        ((a1*b2) - (a2*b1))
      ]
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

    def is_parallel_to?(vec2)
      dot_product(vec2).abs == (magnitude * vec2.magnitude).abs
    end

    def is_orthogonal_to?(vec2, tolerance=1e-10)
      dot_product(vec2).abs < tolerance
    end

    def projection(vec2)
      Vector.new(dot_product(vec2).to_f / dot_product(self)) * self
    end

    def component_parallel_to(vec2)
      unit_vector = vec2.normalize
      weight = dot_product(unit_vector)
      Vector.new(weight) * unit_vector
    end

    def component_orthogonal_to(vec2)
      projection = component_parallel_to(vec2)
      self - projection
    end

    def area_parallelogram(vec2)
      cross_product(vec2).magnitude
    end

    def area_triangle(vec2)
      area_parallelogram(vec2) / 2.0
    end

    private
    def check_size(vec2)
      raise ArgumentError, 'Vectors are of unequal size.' if size != vec2.size
    end
  end
end
