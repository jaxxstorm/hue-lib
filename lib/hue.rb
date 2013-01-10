APP_NAME = 'ruby_hue'
BASE    = 'http://10.10.10.20/api'
# UUID    = 'd79713a3433df3d972ba7c22cb1cc23e'
# Digest::MD5.hexdigest('aa4f6bc0-2045-0130-8cf0-0018de9ecdd0')

require 'net/http'
require 'json'
require 'matrix'

RGB_MATRIX = Matrix[
  [3.233358361244897, -1.5262682428425947, 0.27916711262124544],
  [-0.8268442148395835, 2.466767560486707, 0.3323241608108406],
  [0.12942207487871885, 0.19839858329512317, 2.0280912276039635]
]

require 'hue/bridge.rb'
require 'hue/bulb.rb'
require 'hue/config.rb'

module Hue

  DEVICE_TYPE = "RubyHue"

  def self.device_type
    DEVICE_TYPE
  end

  def self.config
    Hue::Config.default
  end

  class Error < StandardError
    attr_accessor :original_error

    def initialize(message, original_error = nil)
      super(message)
      @original_error = original_error
    end

    def to_s
      if @original_error.nil?
        super
      else
        "#{super}\nCause: #{@original_error.to_s}"
      end
    end
  end

  module API
    class Error < ::Hue::Error
      def initialize(api_error)
        @type = api_error['type']
        @address = api_error['address']
        super(api_error['description'])
      end
    end
  end

end
