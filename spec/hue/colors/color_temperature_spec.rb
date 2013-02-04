# Encoding: UTF-8
require 'spec_helper.rb'

describe Hue::Colors::ColorTemperature do

  context 'when initialized with a valid value' do
    color = described_class.new(500)

    it 'should report the temperature in mireds and kelvins' do
      color.mired.should == 500
      color.kelvin.should == 2000
    end

    it 'should have a string representation' do
      color.to_s.should == "Temperature=2000°K (500 mired)"
    end

    it 'should have a hash representation' do
      color.to_hash.should == {colormode: 'ct', ct: 500}
    end

    it 'should have an RGB representation' do
      color.to_rgb.should == Hue::Colors::RGB.new(255,137,14)
    end

    context 'when allowing change to the temperature value' do
      it 'should go to the max in kelvins' do
        color.kelvin = 7000
        color.kelvin.should == described_class::KELVIN_MAX
        color.mired.should == described_class::MIRED_MIN
      end

      it 'should go to the max in mireds' do
        color.mired = 600
        color.mired.should == described_class::MIRED_MAX
        color.kelvin.should == described_class::KELVIN_MIN
      end

      it 'should go to the min in mireds' do
        color.mired = 100
        color.mired.should == described_class::MIRED_MIN
        color.kelvin.should == described_class::KELVIN_MAX
      end

      it 'should go to the min in kelvins' do
        color.mired = 2000
        color.mired.should == described_class::MIRED_MAX
        color.kelvin.should == described_class::KELVIN_MIN
      end

      it 'should hit the middle' do
        mired_middle = described_class::MIRED_MAX/2
        color.mired = mired_middle
        color.mired.should == mired_middle
        color.kelvin.should == 4000

        kelvin_middle = described_class::KELVIN_MAX/2
        color.kelvin = kelvin_middle
        color.kelvin.should == kelvin_middle
        color.mired.should == 307
      end


    end
  end

  context 'when creating an instance' do
    it 'should set the temperature depending on the value' do
      color = described_class.new(100)
      color.mired.should == described_class::MIRED_MIN

      color = described_class.new(600)
      color.mired.should == described_class::MIRED_MAX

      color = described_class.new(described_class::KELVIN_MIN)
      color.kelvin.should == described_class::KELVIN_MIN

      color = described_class.new(described_class::KELVIN_MAX + 3000)
      color.kelvin.should == described_class::KELVIN_MAX
    end

    it 'should report kelvins as an integer' do
      color = described_class.new(459)
      color.kelvin.should == 2179
    end

    it 'should allow a percentage value for the mired scale' do
      color = described_class.new("0%")
      color.mired.should == described_class::MIRED_MIN

      color = described_class.new("50%")
      color.mired.should == 326

      color = described_class.new("100%")
      color.mired.should == described_class::MIRED_MAX
    end
  end

end
