# Encoding: UTF-8
require 'spec_helper.rb'

describe Hue::Colors::HueSaturation do

  context 'when initialized with valid values' do
    color = described_class.new(2e4, 122)

    it 'should report those values' do
      color.hue.should == 20_000
      color.saturation.should == 122
    end

    it 'should report hue in degrees and a closed unit interval' do
      color.hue_in_degrees.should == 109.86328125
      color.hue_in_unit_interval.should == 0.30517578125
    end

    it 'should report saturation in a closed unit interval' do
      color.saturation_in_unit_interval.should == 0.47843137254901963
    end

    it 'should have a string representation' do
      color.to_s.should == "Hue=20000, Saturation=122"
    end

    it 'should have a hash representation' do
      color.to_hash.should == {hue: 20_000, sat: 122}
    end

    it 'should have an RGB representation' do
      color.to_rgb.should == Hue::Colors::RGB.new(153,255,132)
    end

    context 'when allowing change to the color values' do
      it 'should allow setting the maximum hue' do
        color.hue = 70_000
        color.hue.should == described_class::HUE_MAX
        color.hue_in_degrees.should == 360
        color.hue_in_unit_interval.should == 1.0
      end

      it 'should allow setting the minimum hue' do
        color.hue = -1000
        color.hue.should == described_class::HUE_MIN
        color.hue_in_degrees.should == 0
        color.hue_in_unit_interval.should == 0.0
      end

      it 'should allow setting the maximum saturation' do
        color.saturation = 300
        color.sat.should == described_class::SATURATION_MAX
        color.sat_in_unit_interval.should == 1.0
      end

      it 'should allow setting the minimum saturation' do
        color.saturation = -1
        color.sat.should == described_class::SATURATION_MIN
        color.sat_in_unit_interval.should == 0.0
      end
    end

    context 'when initialized with other values' do
      it 'should accept hue and saturation values' do
        color = described_class.new(3e4, 200)
        color.hue.should == 3e4
        color.sat.should == 200
      end

      it 'should accept a percentage of the hue scale with saturation value' do
        color = described_class.new('20%', 150)
        color.hue.should == 13107
        color.sat.should == 150
      end

      it 'should accept a hue value with a percentage of the saturation scale' do
        color = described_class.new(7e4, '100%')
        color.hue.should == Hue::Colors::HueSaturation::HUE_MAX
        color.sat.should == Hue::Colors::HueSaturation::SATURATION_MAX
      end

      it 'should accept hue and saturation strings' do
        color = described_class.new("30_000", "1333")
        color.hue.should == 3e4
        color.sat.should == Hue::Colors::HueSaturation::SATURATION_MAX
      end
    end

  end

end
