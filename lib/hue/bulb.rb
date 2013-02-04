module Hue
  class Bulb

    BRIGHTNESS_MAX = 255

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

    def brightness_percentage
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

    protected

    def candle(repeat = 15)
      # 0-65536 for hue, 182 per deg. Ideal 30-60 deg (5460-10920)
      stash!
      on if off?

      repeat.times do
        hue = ((rand * 3460) + 5460).to_i
        sat = rand(64) + 170
        bri = rand(32) + 16

        delay = (rand * 0.35) + (@delay ||= 0)
        update(hue: hue, sat: sat, bri: bri, transitiontime: (delay * 10).to_i)
        sleep delay
      end
      restore!
    end

    private

    def options_with_colorstate
      options.merge case state['colormode']
                    when 'ct'
                      {'ct' => state['ct']}
                    when 'xy'
                      {'xy' => state['xy']}
                    when 'hs'
                      {'hue' => state['hue'], 'sat' => state['sat']}
                    end.merge('on' => state['on'], 'bri' => state['bri'])
    end

    def stash!
      @stash ||= options_with_colorstate
    end

    def restore!
      if stash
        update(@stash)
        unstash!
      end
    end

    def unstash!
      @stash = nil
    end

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

    # Experimental Sunrise/Sunset  action
    # this will transition from off and warm light to on and daytime light
    # in a curve that mimics the actual sunrise.

    def perform_sunrise(total_time_in_minutes = 18)
      # total_time / 18 steps == time_per_step
      # the multiplier should be 600 * time per step
      minutes_per_step = total_time_in_minutes / 18.0
      multiplier = (minutes_per_step * 60 * 10).to_i

      perform_sun_transition total_time_in_minutes, sunrise_steps(multiplier)
    end

    def perform_sunrise(total_time_in_minutes = 18)
      multiplier = sunrise_multiplier total_time_in_minutes
      steps = sunrise_steps(multiplier)
      if on?
        puts "ON! #{steps[0][:bri]} :: #{brightness} :: #{brightness > steps[0][:bri]}"
        while brightness >= steps[0][:bri]
          steps.shift
        end
      end
      steps.each_with_index do |step, i|
        update step.merge(on: true)
        sleep(step[:transitiontime] / 10.0)
      end
    end

    def perform_sunset(total_time_in_minutes = 18)
      multiplier = sunrise_multiplier total_time_in_minutes
      steps = sunset_steps(multiplier)
      if on?
        puts "ON! #{steps[0][:bri]} :: #{brightness} :: #{brightness > steps[0][:bri]}"
        while brightness <= steps[0][:bri]
          steps.shift
        end
      end
      steps.each_with_index do |step, i|
        update step.merge(on: true)
        sleep(step[:transitiontime] / 10.0)
      end
      off
    end

    SUN_STEPS = [ 1.5, 2, 3, 1, 4, 2.5 ]
    SUN_TIMES = [ 3,   3, 3, 1, 2, 1]

    def sunrise_multiplier(total_time_in_minutes)
      # total_time / 18 steps == time_per_step
      # the multiplier should be 600 * time per step
      minutes_per_step = total_time_in_minutes / 18.0
      (minutes_per_step * 60 * 10).to_i
    end

    def sunrise_brightness
      sun_bri_unit  = 10
      SUN_STEPS.inject([0]){|all, i|  all << ((i * sun_bri_unit) + all[-1]).to_i } << 255
    end

    def sunrise_temps
      sun_temp_unit = 16
      SUN_STEPS.inject([500]){|all, i| all << (all[-1] - (i * sun_temp_unit)).to_i} << 200
    end

    def sunrise_times
      [0, SUN_TIMES, 5].flatten
    end

    def sunset_times
      [0, 5, SUN_TIMES.reverse].flatten
    end

    def sunrise_steps(multiplier = 600)
      bri_steps = sunrise_brightness
      tmp_steps = sunrise_temps

      steps = []
      sunrise_times.each_with_index do |t, i|
        steps << {bri: bri_steps[i], ct: tmp_steps[i], transitiontime: (t * multiplier)}
      end
      steps
    end

    def sunset_steps(multiplier = 600)
      bri_steps = sunrise_brightness.reverse
      tmp_steps = sunrise_temps.reverse

      steps = []
      sunset_times.each_with_index do |t, i|
        steps << {bri: bri_steps[i], ct: tmp_steps[i], transitiontime: (t * multiplier)}
      end
      steps
    end

  end
end
