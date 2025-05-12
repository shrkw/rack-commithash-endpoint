# frozen_string_literal: true

require 'test_helper'
require 'rack/builder'
require 'rack/test'
require 'rack/lint'

class TestEndpoint < Minitest::Test
  include Rack::Test::Methods

  def test_that_it_has_a_version_number
    refute_nil ::Rack::Commithash::Endpoint::VERSION
  end

  def app
    options = @options || {}
    Rack::Builder.new do
      use Rack::Commithash::Endpoint, **options
      run lambda { |_env|
        [
          200,
          { 'Content-Type' => 'text/plain' },
          ['Original Response']
        ]
      }
    end
  end

  def setup
    @options = {}
    @path = '/__revision__'
    # Store the original ENV value to restore it later
    @original_commit_hash = ENV.fetch('COMMIT_HASH', nil)
    ENV['COMMIT_HASH'] = 'abc123'
  end

  def teardown
    # Restore the original ENV value
    ENV['COMMIT_HASH'] = @original_commit_hash
  end

  def test_returns_commit_hash_at_default_path
    get @path

    assert_equal 200, last_response.status
    assert_equal '{"revision":"abc123"}', last_response.body
    assert_equal 'application/json', last_response.content_type
    assert_equal '{"revision":"abc123"}'.bytesize.to_s, last_response.headers['Content-Length']
  end

  def test_passes_through_non_revision_requests
    get '/'

    assert_equal 200, last_response.status
    assert_equal 'Original Response', last_response.body
  end

  def test_uses_custom_path
    @options = { path: '/version' }
    get '/version'

    assert_equal 200, last_response.status
    assert_equal '{"revision":"abc123"}', last_response.body
    assert_equal 'application/json', last_response.content_type
    assert_equal '{"revision":"abc123"}'.bytesize.to_s, last_response.headers['Content-Length']
  end

  def test_uses_custom_env_var
    @options = { env_var: 'MY_CUSTOM_HASH' }
    ENV['MY_CUSTOM_HASH'] = 'custom123'
    get @path

    assert_equal '{"revision":"custom123"}', last_response.body
    assert_equal 'application/json', last_response.content_type
    assert_equal '{"revision":"custom123"}'.bytesize.to_s, last_response.headers['Content-Length']
    ENV.delete('MY_CUSTOM_HASH')
  end

  def test_returns_unknown_when_env_var_not_set
    ENV.delete('COMMIT_HASH')
    get @path

    assert_equal '{"revision":"unknown"}', last_response.body
    assert_equal 'application/json', last_response.content_type
    assert_equal '{"revision":"unknown"}'.bytesize.to_s, last_response.headers['Content-Length']
  end

  def test_plain_text_response
    @options = { json_format: false }
    get @path

    assert_equal 200, last_response.status
    assert_equal 'abc123', last_response.body
    assert_equal 'text/plain', last_response.content_type
    assert_equal '6', last_response.headers['Content-Length']
  end

  def test_app_is_rack_lint_compatible
    linted_app = Rack::Lint.new(app)
    get @path, {}, 'rack.input' => StringIO.new
    response = Rack::MockRequest.new(linted_app).get(@path)

    assert_equal 200, response.status
    assert_equal '{"revision":"abc123"}', response.body
  end
end
