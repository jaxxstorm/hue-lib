# Encoding: UTF-8

module Hue
  module Colors
    class RGB < Color

      MIN = 0
      MAX = 255

      def self.ranged(value)
        super(MIN, value, MAX)
      end

      public

      attr_reader :red, :green, :blue

      def initialize(*rgb)
        red, green, blue = rgb
        self.red = red
        self.green = green
        self.blue = blue
      end

      def red=(value)
        @red = parse(value)
      end

      def green=(value)
        @green = parse(value)
      end

      def blue=(value)
        @blue = parse(value)
      end

      def to_hash
        max = MAX.to_f
        red, green, blue = self.red / max, self.green / max, self.red / max

        max = [red, green, blue].max
        min = [red, green, blue].min
        h, s, l = 0, 0, ((max + min) / 2 * 255)

        d = max - min
        s = max == 0 ? 0 : (d / max * 255)

        h = case max
            when min
              0 # monochromatic
            when red
              (green - blue) / d + (green < blue ? 6 : 0)
            when green
              (blue - red) / d + 2
            when blue
              (red - green) / d + 4
            end * 60  # / 6 * 360

        h = (h * HueSaturation::HUE_SCALE).to_i
        {hue: h, sat: s.to_i, bri: 1.0}
      end

      def to_s
        "RGB≈#{rgb}"
      end

      def to_rgb
        self
      end

      def ==(rhs)
        rhs.is_a?(RGB) &&
          [:red, :green, :blue].all? { |m| self.send(m) == rhs.send(m) }
      end

      protected

      def ranged(value)
        self.class.ranged(value.to_i).round
      end

      private

      def rgb
        [red, green, blue]
      end

      def unit_to_rgb_scale(value)
        (value * (MAX - MIN) + MIN).round
      end

      def parse(value)
        if scale = Hue.percent_to_unit_interval(value)
          unit_to_rgb_scale(scale)
        else
          ranged(value)
        end
      end

    end
  end
end
