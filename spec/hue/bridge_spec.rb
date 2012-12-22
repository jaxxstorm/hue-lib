require 'spec_helper.rb'

describe Hue::Bridge do

  def self.klass
    Hue::Bridge
  end

  def klass
    self.class.klass
  end

  # it 'should acts as a singleton and give access to the instance' do
  #   klass.instance.should be_a_kind_of(Hue::Bridge)
  # end

  it 'should allow registering a new bridge' do
    pending
  end

  it 'should allow un-registering a bridge' do
    pending
  end

  context 'when instantiated with a given config' do
    bridge = klass.new

    # before(:each) do
    #   with_fake_index_request
    # end

    it 'should report the bridge status' do
      with_fake_request_base
      bridge.status.should == api_reply(:base)
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
  end

end
