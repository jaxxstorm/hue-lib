require 'spec_helper'

describe Hue::Config::Application do

  mock_application_config_path

  after(:all) do
    create_test_application_config
  end

  it 'should report the config file location' do
    described_class.file_path.should == TEST_CONFIG_APPLICATION_PATH
  end

  it "should throw and error if a named config doesn't exist" do
    lambda do
      described_class.named('not_default')
    end.should raise_error(Hue::Config::NotFound, /Config named (.*) not found/)
  end

  context 'with a config file, containing a default' do
    config = described_class.default

    it "should give the default config and report it's values" do
      config.name == described_class::STRING_DEFAULT
      config.base_id == TEST_CONFIG_APPLICATION[config.name][described_class::STRING_BASE_ID]
      config.identifier == TEST_CONFIG_APPLICATION[config.name][described_class::STRING_IDENTIFIER]
    end

    it 'should allow deleting the default config from the file' do
      config.delete
      YAML.load_file(described_class.file_path)[described_class::STRING_DEFAULT].should be_nil
    end
  end

  context 'given an new config' do
    config = described_class.new('http://someip/api', 'some_id', 'not_default')

    it 'should report the values' do
      config.name == 'not_default'
      config.base_id == 'http://someip/api'
      config.identifier == 'not_default'
    end

    it 'should allow writing the new config to file' do
      config.write
      YAML.load_file(described_class.file_path)['not_default'].should be_a(Hash)
    end

    it 'should allow fetching that name config' do
      named_config = described_class.named('not_default')
      named_config.should == config
    end

    it 'should allow deleting that named config from the file' do
      config.delete
      YAML.load_file(described_class.file_path)['not_default'].should be_nil
    end
  end

end
