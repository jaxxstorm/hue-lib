module Hue
  module Animations
    module Sunrise

      SUN_STEPS = [ 1.5, 2, 3, 1, 4, 2.5 ]
      SUN_TIMES = [ 3,   3, 3, 1, 2, 1]

      public

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
          update step.merge(:on => true)
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
          update step.merge(:on => true)
          sleep(step[:transitiontime] / 10.0)
        end
        off
      end

      private


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
          steps << {:bri => bri_steps[i], :ct => tmp_steps[i], :transitiontime => (t * multiplier)}
        end
        steps
      end

      def sunset_steps(multiplier = 600)
        bri_steps = sunrise_brightness.reverse
        tmp_steps = sunrise_temps.reverse

        steps = []
        sunset_times.each_with_index do |t, i|
          steps << {:bri => bri_steps[i], :ct => tmp_steps[i], :transitiontime => (t * multiplier)}
        end
        steps
      end

    end
  end
end
