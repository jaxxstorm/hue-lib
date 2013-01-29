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

    it "should report the hue, brightness and saturation" do
      bulb.hue.should == 13234
      bulb.brightness.should == 146
      bulb.bri.should == 146
      bulb.saturation.should == 208
      bulb.sat.should == bulb.saturation
    end

    it "should report the color temperature and color mode" do
      bulb.color_temperature.should == 459
      bulb.ct.should == bulb.color_temperature
      bulb.color_mode.should == 'ct'
      bulb.color_mode.should == bulb.colormode
    end

    it "should report the alert state" do
      bulb.blinking?.should be_false
      bulb.solid?.should be_true
    end

    context 'by changing state' do

      it 'should allow turning bulps on and off' do
        with_fake_update('lights/1/state', on: true)
        bulb.on.should be_true

        with_fake_update('lights/1/state', on: false)
        bulb.off.should be_true
      end

      it 'should allow setting hue, saturation and brightness' do
        with_fake_update('lights/1/state', hue: 21845)
        bulb.hue = 120
        bulb.hue.should == 21845

        with_fake_update('lights/1/state', sat: 1293)
        bulb.saturation = 1293
        bulb.saturation.should == 1293

        with_fake_update('lights/1/state', bri: 233)
        bulb.brightness = 233
        bulb.brightness.should == 233
      end

      it 'should allow setting blink, solid and flash alerts' do
        with_fake_update('lights/1/state', alert: 'lselect')
        bulb.blink
        bulb.blinking?.should be_true

        with_fake_update('lights/1/state', alert: 'none')
        bulb.solid
        bulb.solid?.should be_true

        with_fake_update('lights/1/state', alert: 'select') do
          with_fake_update('lights/1/state', alert: 'none')
          bulb.flash
          bulb.solid?.should be_true
        end
      end

    end

  end

end
