require 'spec_helper.rb'

class Hue::Config::AbstractTest < Hue::Config::Abstract
  private
  def add_self_to_yaml(yaml)
    yaml[name] = { 1 => :test}
  end
end

describe Hue::Config::Abstract do

  before(:all) do
    create_test_application_config
  end

  context 'given an new config' do
    config = described_class.new('test', TEST_CONFIG_APPLICATION_PATH)

    it 'should report the values' do
      config.name == 'test'
      config.path == TEST_CONFIG_APPLICATION_PATH
    end

    it 'should allow writing the new config to file' do
      config.write
      YAML.load_file(config.path)['test'].should be_a(Hash)
    end

    it 'should allow deleting that named config from the file' do
      config.delete
      YAML.load_file(config.path)['test'].should be_nil
    end
  end

  context 'given an existing config' do
    config = described_class.new('test', EMPTY_CONFIG_FILE)

    it 'should allow writing to the file' do
      config.write
      YAML.load_file(config.path)['test'].should be_a(Hash)
      config.delete
    end
  end

end
