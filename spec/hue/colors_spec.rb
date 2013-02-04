require 'spec_helper.rb'

describe Hue::Colors do

  context 'when #parse_state is used' do
    it 'can return a ColorTemperature' do
      color = described_class.parse_state({'colormode' => 'ct', 'ct' => 500})
      color.should be_a(Hue::Colors::ColorTemperature)
      color.mired.should == 500
    end

    it 'can return HueSaturation' do
      color = described_class.parse_state({'colormode' => 'hs', 'hue' => 30_000, 'sat' => 150})
      color.should be_a(Hue::Colors::HueSaturation)
      color.hue.should == 30_000
      color.sat.should == 150
    end

    it 'can return XY' do
      color = described_class.parse_state({'colormode' => 'xy', 'xy' => [0.8, 0.2]})
      color.should be_a(Hue::Colors::XY)
      color.x.should == 0.8
      color.y.should == 0.2
    end

    it 'throws error if no mode is passed' do
      lambda do
        described_class.parse_state({})
      end.should raise_error(Hue::Error, /Unknown or missing state/)
    end
  end

  context 'when #parse is used' do
    it 'can return a ColorTemperature with single value' do
      color = described_class.parse("5000")
      color.should be_a(Hue::Colors::ColorTemperature)
      color.kelvin.should == 5000

      color = described_class.parse(130)
      color.should be_a(Hue::Colors::ColorTemperature)
      color.mired.should == Hue::Colors::ColorTemperature::MIRED_MIN

      color = described_class.parse("100%")
      color.should be_a(Hue::Colors::ColorTemperature)
      color.mired.should == Hue::Colors::ColorTemperature::MIRED_MAX
    end

    it 'can return HueSaturation' do
      color = described_class.parse(*[3e4, 200])
      color.should be_a(Hue::Colors::HueSaturation)
      color.hue.should == 3e4
      color.sat.should == 200

      color = described_class.parse(*['20%', 150])
      color.should be_a(Hue::Colors::HueSaturation)
      color.hue.should == 13107
      color.sat.should == 150

      color = described_class.parse(*[7e4, '100%'])
      color.should be_a(Hue::Colors::HueSaturation)
      color.hue.should == Hue::Colors::HueSaturation::HUE_MAX
      color.sat.should == Hue::Colors::HueSaturation::SATURATION_MAX
    end

    it 'can return XY' do
      color = described_class.parse(*[0.2, 0.5])
      color.should be_a(Hue::Colors::XY)
      color.x.should == 0.2
      color.y.should == 0.5
    end

    it 'can return RGB' do
      color = described_class.parse(*[0.0, 300, 155])
      color.should be_a(Hue::Colors::RGB)
      color.red.should == 0
      color.green.should == 255
      color.blue.should == 155

      color = described_class.parse(*['10%', '100%', '50%'])
      color.should be_a(Hue::Colors::RGB)
      color.red.should == 26
      color.green.should == 255
      color.blue.should == 128
    end

    it 'throws error if no mode is passed' do
      lambda do
        described_class.parse
      end.should raise_error(Hue::Error, /Unable to parse to color:/)
    end
  end
end
