require 'hue'
require 'webmock'
require 'webmock/rspec'
require 'mocha'

WebMock.disable_net_connect!

TEST_BRIDGE_CONFIG_PATH = File.join(File.dirname(__FILE__), 'config', 'bridges.yml')
TEST_BRIDGE_CONFIG = YAML.load_file(TEST_BRIDGE_CONFIG_PATH)

Hue::Config.expects(:bridges_config_path).at_least_once.returns(TEST_BRIDGE_CONFIG_PATH)
