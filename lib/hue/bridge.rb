require 'socket'
require 'timeout'

module Hue
  class Bridge

    public

    attr_reader :application_id, :bridge_uri

    def initialize(application_id, bridge_uri)
      @application_id = application_id
      @bridge_uri = bridge_uri
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
      create(URI.parse(bridge_uri),
             {"username" => application_id, "devicetype" => Hue.device_type})
    end

    def unregister
      delete(uri('config', 'whitelist', application_id))
    end

    private

    def uri(*args)
      URI.parse([bridge_uri, application_id, args].flatten.reject { |x| x.to_s.strip == '' }.join('/'))
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
