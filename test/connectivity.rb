require 'hue'

bridge = Hue.application

MAX_LIGHTS = 4

@run = true
@command_count = 0
@error_count = 0

trap("SIGINT") do
  @run = false
end

while(@run)
  begin
    @command_count += 1
    number = rand(4)
    light = rand(MAX_LIGHTS)
    case number
    when 0
      puts bridge.status['config']['UTC']
    when 1
      print "#{light + 1} name: "
      puts bridge.bulbs[light].refresh!['name']
    when 2
      print "#{light + 1} on: "
      puts bridge.bulbs[light].on
    when 3
      print "#{light + 1} off: "
      puts bridge.bulbs[light].off
    else
      raise "Unhandled case: #{number}"
    end
  rescue => err
    puts err.message
    @error_count += 1
  end
  sleep 1
end

puts "Command count: #{@command_count}"
puts "Fail count:    #{@error_count}"
puts "Success rate:  #{(1.0 - (@error_count/@command_count.to_f)) * 100}%"
