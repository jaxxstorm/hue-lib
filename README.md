hue-lib
================

This is a Ruby library for controlling the [Philips Hue](http://www.meethue.com) lighting system. 
The API has not yet been released, but there are [several](http://www.nerdblog.com/2012/10/a-day-with-philips-hue.html) [people](http://rsmck.co.uk/hue) working to figure it out.

# WARNING
All of this is very experimental and could permanently damage your awesome (but ridiculously expensive) lightbulbs. As such, exercise extreme caution.

## Getting Started
You can get a [great overview](http://rsmck.co.uk/hue) of the options and limitations of the lights from Ross McKillop.

## Usage
To begin using, fire up the irb console from the project root thus:

```
irb -I lib
```

```ruby
>> require 'hue'
=> true
```

Start by registering your application. Press the button on the bridge and execute

```ruby
>> Hue.register_default
=> #<Hue::Bridge:0x8b9d950 @application_id="4aa41fe737808af3559f3d22ca67a0ca", @base_uri="http://198.168.1.1/api">
```

This will create two config files in your ~/.hue-lib directory.
One for the bridges discovered on your network and one for the registered application.

You can fetch the default application thus:

```ruby
>> bridge = Hue.application
=> #<Hue::Bridge:0x8b9d950 @application_id="4aa41fe737808af3559f3d22ca67a0ca", @base_uri="http://198.168.1.1/api">
```

You can see all of the lights attached to your controller by querying the bridge.

```ruby
>> bridge.lights
=> {"1"=>{"name"=>"Bedroom Overhead"}, "2"=>{"name"=>"Living Overhead"}, "3"=>{"name"=>"Standing Lamp"}, "4"=>{"name"=>"Living Cabinet"}}
>> bridge.light_names
=> "1. Bedroom Overhead\n2. Living Overhead\n3. Standing Lamp\n4. Living Cabinet"
```

If you know the ID number of a particular lamp, you can access it directly.

```ruby
>> b = Hue::Bulb.new(bridge, 1)
=> #<Hue::Bulb:0x007fe35a3586b8 @bridge=#<Hue::Bridge:0x007fe35a358690 @id="1">>

# on/off
>> b.on?
=> false

>> b.on
=> true

>> b.on?
=> true

# settings
>> b.settings
=> {"ct"=>343, "on"=>true, "bri"=>240}

>> b.brightness = 128
=> 128

>> b.update hue: 45000, sat: 180
=> true

>> b.settings
=> {"hue"=>45000, "sat"=>180, "on"=>true, "bri"=>128}

# blinking
>> b.blinking?
=> false

>> b.blink

>> b.blinking?
=> true

>> b.solid

>> b.blinking?
=> false
```
