module Hue
  module Animations
    module Candle

      public

      def candle(repeat = 15)
        # 0-65536 for hue, 182 per deg. Ideal 30-60 deg (5460-10920)
        stash!
        on if off?

        repeat.times do
          hue = ((rand * 3460) + 5460).to_i
          sat = rand(64) + 170
          bri = rand(32) + 16

          delay = (rand * 0.35) + (@delay ||= 0)
          update(:hue => hue, :sat => sat, :bri => bri, :transitiontime => (delay * 10).to_i)
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

      def restore!
        if stash
          update(@stash)
          unstash!
        end
      end

      def stash!
        @stash ||= options_with_colorstate
      end

      def unstash!
        @stash = nil
      end

    end
  end
end
