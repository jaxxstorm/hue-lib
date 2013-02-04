require_relative 'animations/candle'
require_relative 'animations/sunrise'

module Hue
  class Bulb

    BRIGHTNESS_MAX = 255

    include Animations::Candle
    include Animations::Sunrise

    public

    attr_reader :id, :bridge
    attr_accessor :options

    def initialize(bridge, light_id, options = {})
      @bridge = bridge
      @id = light_id
      @options = options
    end

    def refresh!
      @status = bridge.get_light_state(id)
    end

    def info
      status.select do |k, value|
        value.is_a?(String)
      end
    end

    def state
      status['state']
    end

    def [](item)
      state[item.to_s]
    end

    def name
      status['name']
    end

    def name=(_name)
      update(name: _name)
    end

    def on?
      self[:on]
    end

    def off?
      !on?
    end

    def on
      update(on: true)
      on?
    end

    def off
      update(on: false)
      off?
    end

    def brightness
      self[:bri]
    end

    alias :bri :brightness

    def brightness=(bri)
      if scale = Hue.percent_to_unit_interval(bri)
        update(bri: (scale * BRIGHTNESS_MAX).round)
      else
        update(bri: bri.to_i)
      end
      brightness
    end

    alias :bri= :brightness=

    def brightness_in_unit_interval
      brightness / BRIGHTNESS_MAX.to_f
    end

    def brightness_percent
      (brightness_in_unit_interval * 100).round
    end

    def color_mode
      self[:colormode]
    end

    alias :colormode :color_mode

    def color
      set_color
    end

    def color=(col)
      update(col.to_hash)
      set_color
    end

    def blinking?
      !solid?
    end

    def solid?
      'none' == self['alert']
    end

    def blink
      update(alert: 'lselect')
    end

    def solid
      update(alert: 'none')
    end

    def flash
      update(alert: 'select')
      update(alert: 'none')
    end

    def transition_time
      # transition time in seconds
      (options[:transitiontime] || 1).to_f / 10
    end

    def transition_time=(time)
      # transition time in seconds
      self.options[:transitiontime] = (time * 10).to_i
    end

    private

    def status
      @status || refresh!
    end

    def set_color
      @color = Colors.parse_state(state)
    end

    def update(settings = {})
      if bridge.set_light_state(id, options.merge(settings))
        if @status
          settings.each do |key, value|
            @status['state'][key.to_s] = value # or refresh!
          end
        end
      end
    end

  end
end
