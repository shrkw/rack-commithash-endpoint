# frozen_string_literal: true

require_relative 'endpoint/version'

module Rack
  module Commithash
    # Rack::Commithash provides a middleware that exposes the current Git commit hash
    # through a configurable endpoint. This is useful for identifying the exact version
    # of your application in production environments, facilitating debugging and deployment tracking.
    class Endpoint
      class Error < StandardError; end

      DEFAULT_REQUEST_PATH = '/__revision__'
      DEFAULT_ENV_VAR = 'COMMIT_HASH'

      # @param [#call] app
      # @param [String] env_var
      # @param [String] path
      # @param [Boolean] json_format
      def initialize(
        app,
        env_var: DEFAULT_ENV_VAR,
        path: DEFAULT_REQUEST_PATH,
        json_format: true
      )
        @app = app
        @path = path
        commit_hash = ENV[env_var] || 'unknown'
        @body, @length, @content_type = build_response(commit_hash, json_format)
      end

      # @param [Hash] env Rack env.
      # @return [Array] Rack response.
      def call(env)
        if env['PATH_INFO'] == @path
          [
            200,
            {
              'content-length' => @length,
              'content-type' => @content_type
            },
            [@body]
          ]
        else
          @app.call(env)
        end
      end

      private

      # Builds the response body, length, and content type based on the commit hash and format.
      # @param [String] commit_hash The commit hash to include in the response.
      # @param [Boolean] json_format Whether to return the response in JSON format.
      # @return [Array] An array containing the response body, its length, and content type.
      def build_response(commit_hash, json_format)
        if json_format
          body = "{\"revision\":\"#{commit_hash}\"}"
          content_type = 'application/json'
        else
          body = commit_hash
          content_type = 'text/plain'
        end
        [body, body.bytesize.to_s, content_type]
      end
    end
  end
end
