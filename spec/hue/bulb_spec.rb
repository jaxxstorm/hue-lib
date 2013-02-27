require 'spec_helper.rb'

describe Hue::Bulb do

  context 'when instantiated with a given bridge and id' do
    bulb = described_class.new(test_bridge, 1)

    before(:all) do
      with_fake_request('lights/1')
      @test_status = api_reply('lights/1')
    end

    it 'should report the bulb state' do
      bulb.state.should == @test_status['state']
    end

    it 'should report the bulb info' do
      info = api_reply('lights/1')
      info.delete('state')
      info.delete('pointsymbol')
      bulb.info.should == info
    end

    it "should report it's name" do
      bulb.name.should == @test_status['name']
    end

    it "should report if it's on" do
      bulb.on?.should be_false
    end

    it "should report if it's off" do
      bulb.off?.should be_true
    end

    it "should report the brightness and color mode" do
      bulb.brightness.should == 146
      bulb.bri.should == 146
      bulb.color_mode.should == 'ct'
      bulb.color_mode.should == bulb.colormode
    end

    it "should report the color" do
      color = bulb.color
      color.should be_a(Hue::Colors::ColorTemperature)
      color.mired.should == 459
      color.kelvin.should == 2179
    end

    it "should report the alert state" do
      bulb.alert.should == 'none'
      bulb.blinking?.should be_false
      bulb.solid?.should be_true
    end

    it "should report the effect state" do
      bulb.effect?.should be_false
      bulb.effect.should == 'none'
      bulb.color_loop?.should be_false
    end

    it "should report the transition time" do
      bulb.transition_time.should == 0
    end

    context 'by changing state' do

      it 'should allow turning bulps on and off' do
        with_fake_update('lights/1/state', :on => true)
        bulb.on.should be_true

        with_fake_update('lights/1/state', :on => false)
        bulb.off.should be_true
      end

      it 'should allow changing the name' do
        with_fake_update('lights/1', :name => 'New name')
        bulb.name = 'New name'
        bulb.name.should == 'New name'
      end

      it 'should allow setting hue, saturation and brightness' do
        color = Hue::Colors::HueSaturation.new(21845, 1293)

        with_fake_update('lights/1/state', :hue => 21845, :sat => 255)
        set_color = (bulb.color = color)
        set_color.hue.should == 21845
        set_color.saturation.should == 255
      end

      it 'should allow setting brightness as a number, percentage or string' do
        with_fake_update('lights/1/state', :bri => 233)
        bulb.brightness = 233
        bulb.brightness.should == 233

        with_fake_update('lights/1/state', :bri => 128)
        bulb.brightness = "50%"
        bulb.brightness.should == 128
        bulb.brightness_in_unit_interval.should == 0.5019607843137255
        bulb.brightness_percent.should == 50

        with_fake_update('lights/1/state', :bri => 128)
        bulb.brightness = "128"
        bulb.brightness.should == 128
      end

      it 'should allow setting blink, solid and flash alerts' do
        with_fake_update('lights/1/state', :alert => 'lselect')
        bulb.blink
        bulb.blinking?.should be_true

        with_fake_update('lights/1/state', :alert => 'none')
        bulb.solid
        bulb.solid?.should be_true

        with_fake_update('lights/1/state', :alert => 'select') do
          with_fake_update('lights/1/state', :alert => 'none')
          bulb.flash
          bulb.solid?.should be_true
        end

        with_fake_update('lights/1/state', :alert => 'crap') do
          bulb.alert = 'crap'
        end
      end

      it 'should allow setting colorloop, and effect' do
        with_fake_update('lights/1/state', :effect => 'new')
        bulb.effect = 'new'
        bulb.effect.should == 'new'
        bulb.effect?.should be_true

        with_fake_update('lights/1/state', :effect => 'colorloop')
        bulb.colorloop
        bulb.effect.should == 'colorloop'
        bulb.effect?.should be_true
        bulb.color_loop?.should be_true

        with_fake_update('lights/1/state', :effect => 'none')
        bulb.clear_effect
        bulb.effect.should == 'none'

        with_fake_update('lights/1/state', :effect => 'colorloop')
        bulb.color_loop
        bulb.effect.should == 'colorloop'
      end

      it 'should allow setting the transitions time, and employ it for a state change' do
        bulb.transition_time = 10

        with_fake_update('lights/1/state', :transitiontime => 100, :bri => 255)
        bulb.brightness = 255
      end

    end

  end

end
