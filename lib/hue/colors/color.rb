module Hue
  module Colors
    class Color

      ERROR_METHOD_NOT_IMPLEMENTED = 'method-not-implemented'

      def self.ranged(min, val, max)
        [[min, val].max, max].min
      end

      public

      def to_hash
        raise ERROR_METHOD_NOT_IMPLEMENTED
      end

      def to_s
        raise ERROR_METHOD_NOT_IMPLEMENTED
      end

      def to_rgb
        raise ERROR_METHOD_NOT_IMPLEMENTED
      end

      protected


      def ranged(min, val, max)
        # For convinence and polymorphism
        self.class.ranged(min, val, max)
      end

    end
  end
end
