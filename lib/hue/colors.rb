require_relative 'colors/color'
require_relative 'colors/hue_saturation'
require_relative 'colors/color_temperature'
require_relative 'colors/xy'
require_relative 'colors/rgb'

module Hue
  module Colors

    def self.parse(*args)
      case args.size
      when 1
        Colors::ColorTemperature.new(args.first)
      when 2
        a,b = args.first.to_f, args.last.to_f
        if a > 1.0
          Colors::HueSaturation.new(args.first, args.last)
        else
          Colors::XY.new(*args)
        end
      when 3
        Colors::RGB.new(*args)
      else
        raise Error.new("Unable to parse to color: #{args.inspect}")
      end
    end

    def self.parse_state(state)
      case state['colormode']
      when 'ct'
        Colors::ColorTemperature.new(state['ct'])
      when 'xy'
        Colors::XY.new(*state['xy'])
      when 'hs'
        Colors::HueSaturation.new(state['hue'], state['sat'])
      else
        raise Error.new("Unknown or missing state: #{state.inspect}")
      end
    end

  end
end
