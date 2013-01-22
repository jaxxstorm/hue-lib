require 'hue'
require 'webmock'
require 'webmock/rspec'
require 'mocha'

WebMock.disable_net_connect!

SPEC_DIR = File.dirname(__FILE__)
TEST_CONFIG_APPLICATION_PATH = File.join(SPEC_DIR, 'config', 'applications.yml')
TEST_CONFIG_APPLICATION = YAML.load_file(TEST_CONFIG_APPLICATION_PATH)
TEST_JSON_DATA_PATH = File.join(SPEC_DIR, 'json')
TEST_ENDPOINT = "http://localhost/api"

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
  stub = stub_request(:post, join_paths(TEST_ENDPOINT, named))
  stub.with(:body => post_body.to_json) unless post_body.empty?
  stub.to_return(:status => 200, :body => api_reply_json(join_paths(named, post_reply_name)), :headers => {})

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

def with_stdout(expected_output, &block)
  original_stdout = $stdout
  new_stdout = StringIO.new
  begin
    $stdout = new_stdout
    yield
    new_stdout.seek(0)
    output = new_stdout.read
    output.should match(expected_output)
  ensure
    new_stdout.close
    $stdout = original_stdout
  end
end

def with_temp_config_path(write_config = false)
  temp_config_path = File.join(SPEC_DIR, 'config', 'temp')
  FileUtils.mkdir_p(temp_config_path)
  temp_config = File.join(temp_config_path, 'applications.yml')
  if write_config
    create_test_application_config(temp_config)
  end
  Hue::Config::Application.expects(:config_path).at_least_once.returns(temp_config)

  begin
    yield
  ensure
    FileUtils.rm_f(temp_config)
    mock_bridge_config_path
  end
end

def create_test_application_config(path = TEST_CONFIG_APPLICATION_PATH)
  File.open(path, 'w' ) do |out|
    YAML.dump(TEST_CONFIG_APPLICATION, out)
  end
end

def mock_bridge_config_path
  Hue::Config::Application.expects(:config_path).at_least_once.returns(TEST_CONFIG_APPLICATION_PATH)
end

mock_bridge_config_path
