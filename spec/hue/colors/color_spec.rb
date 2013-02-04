require 'spec_helper.rb'

describe Hue::Colors::Color do

  context 'implements a ranged method: max > value > min' do
    it 'should return the min when value < min' do
      described_class.ranged(0, -1, 2).should == 0
    end

    it 'should return the max when value > max' do
      described_class.ranged(0, 3, 2).should == 2
    end

    it 'should return the value when max > value > min' do
      described_class.ranged(0, 1, 2).should == 1
    end
  end

  def abstract_method(method)
    abstract_color = described_class.new
    abstract_color.should respond_to(method)
    lambda do
      abstract_color.send(method)
    end.should raise_error(described_class::ERROR_METHOD_NOT_IMPLEMENTED)
  end

  context 'defines but does not implement methods:' do
    it('#to_hash') { abstract_method(:to_hash) }
    it('#to_s') { abstract_method(:to_s) }
    it('#to_rgb') { abstract_method(:to_rgb) }
  end

end
