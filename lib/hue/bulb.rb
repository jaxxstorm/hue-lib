require 'hue/animations/candle'
require 'hue/animations/sunrise'

module Hue
  class Bulb

    BRIGHTNESS_MAX = 255
    NONE = 'none'
    COLOR_LOOP = 'colorloop'

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
      @status = bridge.get_light(id)
    end

    def info
      status.select do |k, value|
        value.is_a?(String)
      end
    end

    def state
      status['state']
    end

    # Free for all, no checking.
    def state=(value)
      update_state(value)
    end

    def [](item)
      state[item.to_s]
    end

    def name
      status['name']
    end

    def name=(_name)
      update(:name => _name)
    end

    def on?
      self[:on]
    end

    def off?
      !on?
    end

    def on
      update_state(:on => true)
      on?
    end

    def off
      update_state(:on => false)
      off?
    end

    def brightness
      self[:bri]
    end

    alias :bri :brightness

    def brightness=(bri)
      if scale = Hue.percent_to_unit_interval(bri)
        update_state(:bri => (scale * BRIGHTNESS_MAX).round)
      else
        update_state(:bri => bri.to_i)
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
      update_state(col.to_hash)
      set_color
    end

    def effect
      self['effect']
    end

    def effect=(value)
      update_state(:effect => value.to_s)
    end

    def effect?
      NONE != self.effect
    end

    def color_loop
      self.effect = COLOR_LOOP
    end
    alias :colorloop :color_loop

    def color_loop?
      COLOR_LOOP == self.effect
    end

    def clear_effect
      self.effect = NONE
    end

    def alert
      self['alert']
    end

    def alert=(value)
      update_state(:alert => value.to_s)
    end

    def blinking?
      !solid?
    end

    def solid?
      NONE == alert
    end

    def blink
      self.alert = 'lselect'
    end

    def solid
      self.alert = NONE
    end

    def flash
      self.alert = 'select'
      # immediately update to expected state
      @status['state']['alert'] = NONE
    end

    # transition time in seconds
    def transition_time
      (options[:transitiontime] || 0).to_f / 10
    end

    def transition_time=(time)
      self.options[:transitiontime] = (time.to_f * 10).to_i
    end

    private

    def status
      @status || refresh!
    end

    def set_color
      @color = Colors.parse_state(state)
    end

    def update_state(settings = {})
      if bridge.set_light_state(id, options.merge(settings))
        set_status(settings, 'state')
      end
    end

    def update(settings = {})
      if bridge.set_light(id, settings)
        set_status(settings)
      end
    end

    def set_status(settings, key = nil)
      if @status
        status = key ? @status[key] : @status
        settings.each do |key, value|
          status[key.to_s] = value
        end
      end
    end

  end
end
