# Encoding: UTF-8
require 'spec_helper.rb'

describe Hue::Colors::RGB do

  context 'when initialized with a valid values' do
    color = described_class.new(64, 128, 248)

    it 'should report those values' do
      color.red.should == 64
      color.green.should == 128
      color.blue.should == 248
    end

    it 'should have a string representation' do
      color.to_s.should == "RGB≈[64, 128, 248]"
    end

    it 'should have a hash representation' do
      color.to_hash.should == {colormode: 'hs', hue: 21845, sat: 127, bri: 1.0 }
    end

    it 'should have an RGB representation' do
      color.to_rgb.should == color
    end

    context 'when allowing change to the color values' do
      it 'should allow setting the maximum' do
        color.red = 300
        color.red.should == described_class::MAX
        color.green = 255
        color.green.should == described_class::MAX
        color.red = 256
        color.red.should == described_class::MAX
      end

      it 'should allow setting the minimum' do
        color.red = 0
        color.red.should == described_class::MIN
        color.green = -1
        color.green.should == described_class::MIN
        color.red = -256
        color.red.should == described_class::MIN
      end
    end

    context 'when initializing' do
      it 'should allow strings' do
        color = described_class.new('200', '100', '50')
        color.red.should == 200
        color.green.should == 100
        color.blue.should == 50
      end

      it 'should allow percentages' do
        color = described_class.new('10%', '100%', '50%')
        color.red.should == 26
        color.green.should == 255
        color.blue.should == 128
      end
    end
  end

end
