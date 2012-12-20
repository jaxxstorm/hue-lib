require 'spec_helper.rb'

describe Hue::Bridge do

  it 'should acts as a singleton and give access to the instance' do
    Hue::Bridge.instance.should be_a_kind_of(Hue::Bridge)
  end

  it 'should allow registering and new bridge' do
    pending
  end

end
