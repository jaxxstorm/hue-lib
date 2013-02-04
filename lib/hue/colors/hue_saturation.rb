module Hue
  module Colors
    class HueSaturation < Color

      MODE = 'hs'
      HUE_MIN = 0
      HUE_MAX = 65536.0
      HUE_DEGREES = 360
      HUE_SCALE = HUE_MAX / HUE_DEGREES
      SATURATION_MIN = 0
      SATURATION_MAX = 255

      attr_reader :hue, :saturation
      alias :sat :saturation

      public

      def initialize(hue, saturation)
        self.hue = hue
        self.saturation = saturation
      end

      def hue=(value)
        if scale = Hue.percent_to_unit_interval(value)
          @hue = unit_to_hue_interval(scale)
        else
          @hue = ranged(HUE_MIN, value.to_i, HUE_MAX)
        end
      end

      def hue_in_degrees
        self.hue.to_f / HUE_SCALE
      end

      def hue_in_unit_interval
        hue_in_degrees / HUE_DEGREES
      end

      def saturation=(value)
        if scale = Hue.percent_to_unit_interval(value)
          @saturation = unit_to_saturation_interval(scale)
        else
          @saturation = ranged(SATURATION_MIN, value.to_i, SATURATION_MAX)
        end
      end
      alias :sat= :saturation=

      def saturation_in_unit_interval
        self.saturation / SATURATION_MAX.to_f
      end
      alias :sat_in_unit_interval :saturation_in_unit_interval

      def to_s
        "Hue=#{self.hue}, Saturation=#{self.saturation}"
      end

      def to_hash
        {colormode: MODE, hue: hue, sat: saturation}
      end

      def to_rgb(brightness_in_unit_interval = 1.0)
        h, s, v = hue_in_unit_interval, saturation_in_unit_interval, brightness_in_unit_interval
        if s == 0 #monochromatic
          red = green = blue = v
        else

          v = 1.0 # We are setting the value to 1. Don't count brightness here
          i = (h * 6).floor
          f = h * 6 - i
          p = v * (1 - s)
          q = v * (1 - f * s)
          t = v * (1 - (1 - f) * s)

          case i % 6
          when 0
            red, green, blue = v, t, p
          when 1
            red, green, blue = q, v, p
          when 2
            red, green, blue = p, v, t
          when 3
            red, green, blue = p, q, v
          when 4
            red, green, blue = t, p, v
          when 5
            red, green, blue = v, p, q
          end
        end

        RGB.new(red * RGB::MAX, green * RGB::MAX, blue * RGB::MAX)
      end

      private

      def unit_to_hue_interval(value)
        (value * (HUE_MAX - HUE_MIN) + HUE_MIN).round
      end

      def unit_to_saturation_interval(value)
        (value * (SATURATION_MAX - SATURATION_MIN) + SATURATION_MIN).round
      end

    end
  end
end
