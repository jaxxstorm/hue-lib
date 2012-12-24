require 'spec_helper.rb'

describe Hue do

  it 'should report the device type as itself' do
    Hue.device_type.should == Hue::DEVICE_TYPE
  end

  it 'should return the default config' do
    Hue.config.should be_a(Hue::Config)
  end

end
