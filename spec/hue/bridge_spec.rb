require 'spec_helper.rb'

describe Hue::Bridge do

  def self.klass
    Hue::Bridge
  end

  def klass
    self.class.klass
  end

  it 'should allow registering a new bridge' do
    pending
  end

  it 'should allow un-registering a bridge' do
    pending
  end

  context 'when instantiated with the default config' do
    bridge = klass.new

    it 'should report the bridge status' do
      with_fake_request
      bridge.status.should == api_reply(:get_success)
    end

    it 'should report errors' do
      with_fake_request(:lights, :unauthorized)
      lambda do
        bridge.lights
      end.should raise_error(Hue::API::Error, 'unauthorized user')
    end

    it 'should report the bridge lights' do
      with_fake_request(:lights)
      bridge.lights.should == api_reply(:lights)
    end

    it 'should report a simple string of light names' do
      with_fake_request(:lights)
      bridge.light_names.should == "1. Dining\n2. Bedroom Far\n3. Bedroom Near"
    end

    it 'should report the bridge config' do
      with_fake_request(:config)
      bridge.config.should == api_reply(:config)
    end

    it 'should report the light schedules' do
      with_fake_request(:schedules)
      bridge.schedules.should == api_reply(:schedules)
    end

    it 'should return instance of all the bulbs' do
      with_fake_request(:lights)
      bulbs = bridge.bulbs
      bulbs.size.should == 3
      bulbs.each do |bulb|
        bulb.should be_a(Hue::Bulb)
      end
    end

    it 'should allow unregistering an existing config' do
      with_fake_delete('config/whitelist/test_identifier')
      bridge.unregister
    end
  end

  context 'when instantiated with a new config' do
    config = Hue::Config.new(TEST_ENDPOINT, 'new_test_id')
    bridge = klass.new(config)

    it 'should allow registering the new config' do
      with_fake_post(nil, {:username => config.identifier, :devicetype => Hue.device_type})
      bridge.register
    end
  end

end
