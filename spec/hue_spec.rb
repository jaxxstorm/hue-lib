require 'spec_helper.rb'

describe Hue do

  it 'should report the device type as itself' do
    Hue.device_type.should == Hue::DEVICE_TYPE
  end

end
