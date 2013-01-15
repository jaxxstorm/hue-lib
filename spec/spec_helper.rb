require 'hue'
require 'webmock'
require 'webmock/rspec'
require 'mocha'

WebMock.disable_net_connect!

SPEC_DIR = File.dirname(__FILE__)
TEST_BRIDGE_CONFIG_PATH = File.join(SPEC_DIR, 'config', 'bridges.yml')
TEST_BRIDGE_CONFIG = YAML.load_file(TEST_BRIDGE_CONFIG_PATH)
TEST_JSON_DATA_PATH = File.join(SPEC_DIR, 'json')
TEST_ENDPOINT = "http://localhost/api"

Hue::Config.expects(:bridges_config_path).at_least_once.returns(TEST_BRIDGE_CONFIG_PATH)

def with_fake_request_base
  stub_request(:get, "#{TEST_ENDPOINT}/test_identifier").
    to_return(:status => 200, :body => api_reply_json(:get_success), :headers => {})
end

def with_fake_request(named = nil, body_name = nil)
  body_name ||= (named.nil? ? 'get_success' : named)
  stub_request(:get, join_paths(TEST_ENDPOINT, 'test_identifier', named.to_s)).
    to_return(:status => 200, :body => api_reply_json(body_name), :headers => {})
end

def api_reply_json(named)
  file_name = File.join(TEST_JSON_DATA_PATH, named.to_s + '.json')
  json = File.read(file_name)
  json
end

def api_reply(named)
  JSON.parse(api_reply_json(named))
end

def with_fake_update(named, put_body = {})
  stub = stub_request(:put, "#{TEST_ENDPOINT}/test_identifier/#{named.to_s}").
    with(:body => put_body.to_json).
    to_return(:status => 200, :body => api_reply_json(:put_success), :headers => {})

  if block_given?
    yield
    stub.should have_been_requested
  end
end

def with_fake_post(named, post_body = {}, post_reply_name = 'post_success')
  stub = stub_request(:post, join_paths(TEST_ENDPOINT, named)).
    with(:body => post_body.to_json).
    to_return(:status => 200, :body => api_reply_json(join_paths(named, post_reply_name)), :headers => {})

  if block_given?
    yield
    stub.should have_been_requested
  end
end

def with_fake_delete(named, delete_reply = 'delete_success')
  stub = stub_request(:delete, "#{TEST_ENDPOINT}/test_identifier/#{named.to_s}").
    to_return(:status => 200, :body => api_reply_json(join_paths(named, delete_reply)), :headers => {})

  if block_given?
    yield
    stub.should have_been_requested
  end
end

def join_paths(*paths)
  File.join(paths.delete_if { |entry| entry.nil? || entry.empty? })
end
