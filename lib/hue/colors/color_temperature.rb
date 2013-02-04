# Encoding: UTF-8

module Hue
  module Colors
    class ColorTemperature < Color

      MODE = 'ct'
      MEGA = 1e6
      KELVIN_MIN = 2000
      KELVIN_MAX = 6500
      MIRED_MIN = 153
      MIRED_MAX = 500

      public

      def initialize(temperature)
        if scale = Hue.percent_to_unit_interval(temperature)
          self.mired = unit_to_mired_interval(scale)
        else
          # Assume an integer value
          temperature = temperature.to_i
          if temperature >= KELVIN_MIN
            self.kelvin = temperature
          else
            self.mired = temperature
          end
        end
      end

      def mired
        @mired.floor
      end

      def mired=(t)
        @mired = ranged(MIRED_MIN, t, MIRED_MAX)
      end

      def kelvin
        ranged(KELVIN_MIN, MEGA / @mired, KELVIN_MAX).round
      end

      def kelvin=(t)
        self.mired = (MEGA / ranged(KELVIN_MIN, t, KELVIN_MAX))
      end

      def to_hash
        {colormode: MODE, ct: mired}
      end

      def to_s
        "Temperature=#{self.kelvin.to_i}°K (#{self.mired} mired)"
      end

      def to_rgb
        # using method described at
        # http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/
        temp = kelvin / 100

        red = temp <= 66 ? 255 : 329.698727446 * ((temp - 60) ** -0.1332047592)

        green = if temp <= 66
                  99.4708025861 * Math.log(temp) - 161.1195681661
                else
                  288.1221695283 * ((temp - 60) ** -0.0755148492)
                end

        blue = if temp >= 66
                 255
               elsif temp <= 19
                 0
               else
                 138.5177312231 * Math.log(temp - 10) - 305.0447927307
               end

        RGB.new(red, green, blue)
      end

      private

      def unit_to_mired_interval(unit_interval)
        unit_interval * (MIRED_MAX - MIRED_MIN) + MIRED_MIN
      end

    end
  end
end
