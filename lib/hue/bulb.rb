module Hue
  class Bulb

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
      update(bri: bri)
      brightness
    end

    alias :bri= :brightness=

    def hue
      self[:hue]
    end

    HUE_MAX = 65536.0
    HUE_DEGREES = 360
    HUE_SCALE = HUE_MAX / HUE_DEGREES

    def hue=(_hue)
      _hue = (_hue * HUE_SCALE).to_i
      update(hue: _hue)
      hue
    end

    def saturation
      self[:sat]
    end

    alias :sat :saturation

    def saturation=(_sat)
      update(sat: _sat)
      sat
    end

    alias :sat= :saturation=

    def color_temperature
      self[:ct]
    end

    alias :ct :color_temperature

    def color_temperature=(_ct)
      update(ct: [[_ct, 154].max, 500].min)
      colortemp
    end

    alias :ct= :color_temperature=

    def color_mode
      self[:colormode]
    end

    alias :colormode :color_mode

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

    def settings
      options.merge case state['colormode']
                    when 'ct'
                      {'ct' => state['ct']}
                    when 'xy'
                      {'xy' => state['xy']}
                    when 'hs'
                      {'hue' => state['hue'], 'sat' => state['sat']}
                    end.merge('on' => state['on'], 'bri' => state['bri'])
    end

    def rgb
      send %(#{colormode}_to_rgb)
    end

    def red
      rgb[:red]
    end

    def green
      rgb[:green]
    end

    def blue
      rgb[:blue]
    end

    def red=(_red)
      self.rgb = [_red, green, blue]
    end

    def green=(_green)
      self.rgb = [red, _green, blue]
    end

    def blue=(_blue)
      self.rgb = [red, green, _blue]
    end

    def kelvin
      # convert colortemp setting to Kelvin
      1000000 / self['ct']
    end

    def kelvin=(_temp)
      self.colortemp = 1000000 / [_temp, 1].max
    end

    def ct_to_rgb
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

      {   red: [[red,   0].max, 255].min.to_i,
        green: [[green, 0].max, 255].min.to_i,
         blue: [[blue,  0].max, 255].min.to_i
      }

    end

    def xyz
      vals = state['xy']
      vals + [1 - vals.first - vals.last]
    end

    def xy_to_rgb
      values = (RGB_MATRIX * Matrix[xyz].transpose).to_a.flatten.map{|x| [[x * 255, 0].max, 255].min.to_i}
      {   red: values[0],
        green: values[1],
         blue: values[2]
      }
    end

    def hue_in_degrees
      self['hue'].to_f / HUE_SCALE
    end

    def hue_as_decimal
      hue_in_degrees / HUE_DEGREES
    end

    def sat_as_decimal
      self['sat'] / 255.0
    end

    def brightness_as_decimal
      brightness / 255.0
    end

    def hs_to_rgb
      h, s, v = hue_as_decimal, sat_as_decimal, brightness_as_decimal
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

      {   red: [[red * 255,   0].max, 255].min.to_i,
        green: [[green * 255, 0].max, 255].min.to_i,
         blue: [[blue * 255,  0].max, 255].min.to_i
      }
    end

    def rgb=(colors)
      red, green, blue = colors[0] / 255.0, colors[1] / 255.0, colors[2] / 255.0

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

      h = (h * HUE_SCALE).to_i
      update hue: h, sat: s.to_i#, bri: l.to_i
      [h, s, 1.0]
    end

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

    def stash!
      @stash ||= settings
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

    def update(settings = {})
      if bridge.set_light_state(id, options.merge(settings))
        settings.each do |key, value|
          @status['state'][key.to_s] = value # or refresh!
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
