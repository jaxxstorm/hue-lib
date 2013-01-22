require 'spec_helper.rb'

describe Hue::Config::Application do

  TEST_IDENTIFIER = 'test_identifier'

  def self.klass
    Hue::Config::Application
  end

  def klass
    self.class.klass
  end

  after(:all) do
    create_test_application_config
  end

  it 'should report the config file location' do
    klass.config_path.should == TEST_CONFIG_APPLICATION_PATH
  end

  it "should throw and error if a named config doesn't exist" do
    lambda do
      klass.named('not_default')
    end.should raise_error(Hue::Config::NotFound, /Config named (.*) not found/)
  end

  context 'with a bridge config file, containing the default bridge' do
    it "should give the default config and report it's values" do
      config = klass.default
      config.name == klass::STRING_DEFAULT
      config.base_uri == TEST_CONFIG_APPLICATION[config.name][klass::STRING_BASE_URI]
      config.identifier == TEST_CONFIG_APPLICATION[config.name][klass::STRING_IDENTIFIER]
    end
  end

  context 'given an new config' do
    config = klass.new('http://someip/api', 'some_id', 'not_default')

    it 'should report the values' do
      config.name == 'not_default'
      config.base_uri == 'http://someip/api'
      config.identifier == 'not_default'
    end

    it 'should allow writing the new config to file' do
      config.write
      YAML.load_file(klass.config_path)['not_default'].should be_a(Hash)
    end

    it 'should allow fetching that name config' do
      named_config = klass.named('not_default')
      named_config.should == config
    end

    it 'should allow deleting that named config from the file' do
      config.delete
      YAML.load_file(klass.config_path)['not_default'].should be_nil
    end
  end

end
