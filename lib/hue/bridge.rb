require 'socket'
require 'timeout'

module Hue
  class Bridge

    def self.register_default(host = nil)
      if config = Hue.application rescue nil
        raise Hue::Error.new("Default configuration already registered.")
      else
        secret = Hue.one_time_uuid
        puts "Registering app...(#{secret})"
        config = Hue::Config::Application.new(host, secret)
        instance = Hue::Bridge.new(config)
        instance.register
        config.write
        instance
      end
    end

    def self.remove_default
      config = Hue.application
      instance = Hue::Bridge.new(config)
      instance.unregister
      config.delete
      true
    end

    def self.discover(timeout = 2)
      socket  = UDPSocket.new(Socket::AF_INET)
      payload = <<-PAYLOAD
M-SEARCH * HTTP/1.1
HOST: 239.255.255.250:1900
MAN: ssdp:discover
MX: 10
ST: ssdp:all
      PAYLOAD

      socket.send(payload, 0, "239.255.255.250", 1900)
      bridges = Hash.new

      Timeout.timeout(timeout, Hue::Error) do
        loop do
          message, (address_family, port, hostname, ip_add) = socket.recvfrom(1024)
          if message =~ /IpBridge/ && location = /LOCATION: (.*)$/.match(message)
            if uuid = /uuid:(.{36})/.match(message)
              # Assume this is Philips Hue for now.
              bridges[uuid.captures.first] = ip_add
            end
          end
        end
      end
    rescue Hue::Error
      bridges
    end

    public

    attr_reader :application_config

    def initialize(application_config = Hue.application)
      @application_config = application_config
    end

    def status
      index(uri)
    end

    def lights
      index(uri('lights'))
    end

    def light_names
      lights.map { |k,v| "#{k}. #{v['name']}" }.join("\n")
    end

    def config
      index(uri('config'))
    end

    def schedules
      index(uri('schedules'))
    end

    def bulbs
      # puts status['lights'].inspect
      @bulbs ||= lights.keys.map { |b| Bulb.new(self, b) }
    end

    # def remove_schedule(schedule_id)
    #   delete uri('schedules', schedule_id)
    #   puts "Removed schedule #{schedule_id}"
    # end

    # def remove_all_schedules
    #   ids = schedules.keys.map(&:to_i).sort.reverse
    #   puts "Removing #{ids.size} schedule#{'s' if ids.size != 1}..."
    #   ids.each{|x| remove_schedule x}
    # end

    def get_light_state(id)
      index(uri('lights', id))
    end

    def set_light_state(id, state)
      update(uri('lights', id, 'state'), state)
    end

    def register
      create(URI.parse(application_config.base_uri),
             {"username" => application_config.identifier, "devicetype" => Hue.device_type})
    end

    def unregister
      delete(uri('config', 'whitelist', application_config.identifier))
    end

    private

    def uri(*args)
      URI.parse([application_config.base_uri, application_config.identifier, args].flatten.reject { |x| x.to_s.strip == '' }.join('/'))
    end

    def index(url)
      request = Net::HTTP::Get.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      parse_and_check_response(Net::HTTP.new(url.host, url.port).start { |http| http.request(request) })
    end

    def update(url, settings = {})
      request = Net::HTTP::Put.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = settings.to_json
      parse_and_check_response(Net::HTTP.new(url.host, url.port).start { |http| http.request(request) })
    end

    def delete(url, settings = {})
      request = Net::HTTP::Delete.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = settings.to_json
      parse_and_check_response(Net::HTTP.new(url.host, url.port).start{ |http| http.request(request) })
    end

    def create(url, settings = {})
      request = Net::HTTP::Post.new(url.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.body = settings.to_json
      parse_and_check_response(Net::HTTP.new(url.host, url.port).start { |http| http.request(request) })
    end

    def parse_and_check_response(response)
      if display(response)
        json = JSON.parse(response.body)
        if json.is_a?(Array) && error = json.first['error']
          raise Hue::API::Error.new(error)
        else
          json
        end
      else
        raise Hue::Error.new("Unexpected response: #{response.code}, #{response.message}")
      end
    end

    def display(response = nil)
      if response and response.code.to_s != '200'
        # Output to logger
        # puts "Response #{response.code} #{response.message}: #{JSON.parse(response.body).first}"
        false
      else
        # Output to logger
        # puts "Response #{response.code} #{response.message}: #{JSON.parse(response.body).first}"
        true
      end
    end

  end
end
