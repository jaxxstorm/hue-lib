require 'hue'
require 'webmock'
require 'webmock/rspec'
require 'mocha'

WebMock.disable_net_connect!

SPEC_DIR = File.dirname(__FILE__)
TEST_BRIDGE_CONFIG_PATH = File.join(SPEC_DIR, 'config', 'bridges.yml')
TEST_BRIDGE_CONFIG = YAML.load_file(TEST_BRIDGE_CONFIG_PATH)
TEST_JSON_DATA_PATH = File.join(SPEC_DIR, 'json')

Hue::Config.expects(:bridges_config_path).at_least_once.returns(TEST_BRIDGE_CONFIG_PATH)

def with_fake_request_base
  stub_request(:get, "http://localhost/api/test_identifier").
    to_return(:status => 200, :body => api_reply_json(:base), :headers => {})
end

def with_fake_request(named)
  stub_request(:get, "http://localhost/api/test_identifier/#{named.to_s}").
    to_return(:status => 200, :body => api_reply_json(named), :headers => {})
end

def api_reply_json(named)
  file_name = File.join(TEST_JSON_DATA_PATH, named.to_s + '.json')
  json = File.read(file_name)
  json
end

def api_reply(named)
  JSON.parse(api_reply_json(named))
end

def with_fake_update(named, update = {})
  stub = stub_request(:put, "http://localhost/api/test_identifier/#{named.to_s}").
    with(:body => update.to_json).
    to_return(:status => 200, :body => update.to_json, :headers => {})

  if block_given?
    yield
    stub.should have_been_requested
  end
end
