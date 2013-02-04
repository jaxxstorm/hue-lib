# Encoding: UTF-8
require 'spec_helper.rb'

describe Hue::Colors::XY do

  context 'when initialized with a valid values' do
    color = described_class.new(0.5, 0.5)

    it 'should report those values' do
      color.x.should == 0.5
      color.y.should == 0.5
    end

    it 'should have a string representation' do
      color.to_s.should == "XY=[0.5, 0.5]"
    end

    it 'should have a hash representation' do
      color.to_hash.should == {colormode: 'xy', xy: [0.5, 0.5]}
    end

    it 'should have an RGB representation' do
      color.to_rgb.should == Hue::Colors::RGB.new(217,209,41)
    end

    context 'when allowing change to the color values' do
      it 'should allow setting the maximum' do
        color.x = 1.1
        color.x.should == described_class::MAX
        color.y = 2
        color.y.should == described_class::MAX
      end

      it 'should allow setting the minimum' do
        color.x = -1
        color.x.should == described_class::MIN
        color.y = 0
        color.y.should == described_class::MIN
      end
    end
  end

end
