BASE    = 'http://10.10.10.11/api'

require 'net/http'
require 'json'
require 'matrix'
require 'digest/md5'
require 'uuid'

RGB_MATRIX = Matrix[
  [3.233358361244897, -1.5262682428425947, 0.27916711262124544],
  [-0.8268442148395835, 2.466767560486707, 0.3323241608108406],
  [0.12942207487871885, 0.19839858329512317, 2.0280912276039635]
]

module Hue

  DEVICE_TYPE = "hue-lib"

  def self.device_type
    DEVICE_TYPE
  end

  def self.config
    Hue::Config.default
  end

  def self.one_time_uuid
    Digest::MD5.hexdigest(UUID.generate)
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

require 'hue/config.rb'
require 'hue/bridge.rb'
require 'hue/bulb.rb'
