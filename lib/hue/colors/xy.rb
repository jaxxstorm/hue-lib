require 'matrix'
module Hue
  module Colors
    class XY < Color

      MODE = 'xy'
      MIN = 0.0
      MAX = 1.0
      RGB_MATRIX = Matrix[
        [ 3.233358361244897,  -1.5262682428425947,  0.27916711262124544],
        [-0.8268442148395835,  2.466767560486707,   0.3323241608108406 ],
        [ 0.12942207487871885, 0.19839858329512317, 2.0280912276039635 ],
      ]

      public

      attr_reader :x, :y

      def initialize(*xy)
        self.x = xy.first
        self.y = xy.last
      end

      def x=(value)
        @x = ranged(value)
      end

      def y=(value)
        @y = ranged(value)
      end

      def to_hash
        {colormode: MODE, xy: xy}
      end

      def to_s
        "XY=#{xy}"
      end

      def to_rgb
        z = 1 - x - y
        xyz = [x, y, z]
        values = (RGB_MATRIX * Matrix[xyz].transpose).to_a.flatten.map do |x|
          RGB.ranged(x * RGB::MAX).to_i
        end

        RGB.new(*values)
      end

      protected

      def ranged(val)
        super(MIN, val, MAX).to_f
      end

      private

      def xy
        [x,y]
      end

    end
  end
end
