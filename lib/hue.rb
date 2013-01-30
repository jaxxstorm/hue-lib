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

  DEVICE_TYPE = 'hue-lib'
  DEFAULT_UDP_TIMEOUT = 2
  ERROR_DEFAULT_EXISTS = 'Default application already registered.'
  ERROR_NO_BRIDGE_FOUND = 'No bridge found.'

  def self.device_type
    DEVICE_TYPE
  end

  def self.one_time_uuid
    Digest::MD5.hexdigest(UUID.generate)
  end

  def self.register_default
    if default = (Hue::Config::Application.default rescue nil)
      raise Hue::Error.new(ERROR_DEFAULT_EXISTS)
    else
      bridge_config = register_bridges.values.first # Assuming one bridge for now
      secret = Hue.one_time_uuid
      app_config = Hue::Config::Application.new(bridge_config.id, secret)
      puts "Registering app...(#{secret})"
      instance = Hue::Bridge.new(app_config.identifier, bridge_config.uri)
      instance.register
      app_config.write
      instance
    end
  end

  def self.application
    application_config = Hue::Config::Application.default
    bridge_config = Hue::Config::Bridge.find(application_config.base_id)
    bridge_config ||= register_bridges[application_config.base_id]

    if bridge_config.nil?
      raise Error.new("Unable to find bridge: #{application_config.base_id}")
    end

    Hue::Bridge.new(application_config.identifier, bridge_config.uri)
  end

  def self.remove_default
    instance = application
    instance.unregister
    Hue::Config::Application.default.delete
    true
  end

  def self.discover(timeout = DEFAULT_UDP_TIMEOUT)
    bridges = Hash.new
    payload = <<-PAYLOAD
M-SEARCH * HTTP/1.1
HOST: 239.255.255.250:1900
MAN: ssdp:discover
MX: 10
ST: ssdp:all
    PAYLOAD
    broadcast_address = '239.255.255.250'
    port_number = 1900

    socket = UDPSocket.new(Socket::AF_INET)
    socket.send(payload, 0, broadcast_address, port_number)

    Timeout.timeout(timeout, Hue::Error) do
      loop do
        message, (address_family, port, hostname, ip_add) = socket.recvfrom(1024)
        if message =~ /IpBridge/ && location = /LOCATION: (.*)$/.match(message)
          if uuid = /uuid:(.{36})/.match(message)
            # Assume this is Philips Hue for now.
            bridges[uuid.captures.first] = "http://#{ip_add}/api"
          end
        end
      end
    end

  rescue Hue::Error
    bridges
  end

  def self.register_bridges
    bridges = self.discover
    if bridges.empty?
      raise Error.new(ERROR_NO_BRIDGE_FOUND)
    else
      bridges.inject(Hash.new) do |hash, (id, ip)|
        config = Hue::Config::Bridge.new(id, ip)
        config.write
        hash[id] = config
        hash
      end
    end
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

require 'hue/config/abstract'
require 'hue/config/application'
require 'hue/config/bridge'
require 'hue/bridge'
require 'hue/bulb'
