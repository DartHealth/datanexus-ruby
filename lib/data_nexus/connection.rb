# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'json'

module DataNexus
  # HTTP connection wrapper using Faraday
  #
  # Handles authentication, request/response processing, and error handling.
  #
  class Connection
    # @return [Configuration] The connection configuration
    attr_reader :config

    # Initialize a new Connection
    #
    # @param config [Configuration] The configuration object
    def initialize(config)
      @config = config
    end

    # Perform a GET request
    #
    # @param path [String] The API endpoint path
    # @param params [Hash] Query parameters
    # @return [Hash] Parsed JSON response
    def get(path, params = {})
      request(:get, path, params)
    end

    # Perform a POST request
    #
    # @param path [String] The API endpoint path
    # @param body [Hash] Request body
    # @return [Hash] Parsed JSON response
    def post(path, body = {})
      request(:post, path, body)
    end

    # Perform a PATCH request
    #
    # @param path [String] The API endpoint path
    # @param body [Hash] Request body
    # @return [Hash] Parsed JSON response
    def patch(path, body = {})
      request(:patch, path, body)
    end

    private

    # Build the Faraday connection
    #
    # @return [Faraday::Connection]
    def faraday
      @faraday ||= Faraday.new(url: config.base_url, ssl: ssl_options) do |conn|
        configure_request(conn)
        configure_headers(conn)
        configure_timeouts(conn)

        conn.response :raise_error
        conn.adapter Faraday.default_adapter
      end
    end

    def ssl_options
      { verify: config.ssl_verify }
    end

    def configure_request(conn)
      conn.request :json
      conn.request :retry, max: 2, interval: 0.5, backoff_factor: 2,
                           exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed]
    end

    def configure_headers(conn)
      conn.headers['Authorization'] = "apikey #{config.api_key}"
      conn.headers['Content-Type'] = 'application/json'
      conn.headers['Accept'] = 'application/json'
      conn.headers['User-Agent'] = "data-nexus-ruby/#{DataNexus::VERSION}"
    end

    def configure_timeouts(conn)
      conn.options.timeout = config.timeout
      conn.options.open_timeout = config.open_timeout
    end

    # Perform an HTTP request
    #
    # @param method [Symbol] HTTP method (:get, :post, :patch)
    # @param path [String] The API endpoint path
    # @param params_or_body [Hash] Query params (GET) or body (POST/PATCH)
    # @return [Hash] Parsed JSON response
    def request(method, path, params_or_body = {})
      response = faraday.public_send(method, path, params_or_body)
      parse_response(response)
    rescue Faraday::TimeoutError => e
      raise TimeoutError, "Request timed out: #{e.message}"
    rescue Faraday::ConnectionFailed => e
      raise ConnectionError, "Connection failed: #{e.message}"
    rescue Faraday::ClientError, Faraday::ServerError => e
      handle_error_response(e)
    end

    # Parse the response body as JSON
    #
    # @param response [Faraday::Response]
    # @return [Hash]
    def parse_response(response)
      return {} if response.body.nil? || response.body.empty?

      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError
      { raw_body: response.body }
    end

    # Handle error responses and raise appropriate exceptions
    #
    # @param error [Faraday::Error]
    # @raise [APIError] The appropriate error subclass
    def handle_error_response(error)
      status, body, message = extract_error_details(error)
      error_class = HTTP_STATUS_ERRORS[status] || APIError

      raise_api_error(error_class, message, status, body, error.response)
    end

    def extract_error_details(error)
      status = error.response&.dig(:status)
      body = parse_error_body(error.response&.dig(:body))
      message = extract_error_message(body, error.message)

      [status, body, message]
    end

    def raise_api_error(error_class, message, status, body, response)
      if error_class == RateLimitError
        retry_after = response&.dig(:headers, 'retry-after')&.to_i
        raise error_class.new(message, status: status, response_body: body, retry_after: retry_after)
      end

      raise error_class.new(message, status: status, response_body: body)
    end

    # Parse error response body
    #
    # @param body [String, nil]
    # @return [Hash, nil]
    def parse_error_body(body)
      return nil if body.nil? || body.empty?

      JSON.parse(body, symbolize_names: true)
    rescue JSON::ParserError
      { raw_body: body }
    end

    # Extract a human-readable error message
    #
    # @param body [Hash, nil]
    # @param default [String]
    # @return [String]
    def extract_error_message(body, default)
      return default unless body.is_a?(Hash)

      body[:error] || body[:message] || body[:errors]&.first || default
    end
  end
end
