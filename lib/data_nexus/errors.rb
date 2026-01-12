# frozen_string_literal: true

module DataNexus
  # Base error class for all DataNexus errors
  class Error < StandardError
    # @return [Integer, nil] HTTP status code if applicable
    attr_reader :status

    # @return [Hash, nil] Response body if available
    attr_reader :response_body

    # Initialize a new Error
    #
    # @param message [String] Error message
    # @param status [Integer, nil] HTTP status code
    # @param response_body [Hash, nil] Parsed response body
    def initialize(message = nil, status: nil, response_body: nil)
      @status = status
      @response_body = response_body
      super(message)
    end
  end

  # Raised when the API key is missing or invalid
  class ConfigurationError < Error; end

  # Base class for HTTP errors returned by the API
  class APIError < Error; end

  # Raised when authentication fails (401)
  class AuthenticationError < APIError; end

  # Raised when the request is forbidden (403)
  class ForbiddenError < APIError; end

  # Raised when a resource is not found (404)
  class NotFoundError < APIError; end

  # Raised when the request is invalid (400)
  class BadRequestError < APIError; end

  # Raised when validation fails (422)
  class UnprocessableEntityError < APIError; end

  # Raised when rate limit is exceeded (429)
  class RateLimitError < APIError
    # @return [Integer, nil] Seconds until rate limit resets
    attr_reader :retry_after

    def initialize(message = nil, status: nil, response_body: nil, retry_after: nil)
      @retry_after = retry_after
      super(message, status: status, response_body: response_body)
    end
  end

  # Raised when there's a server error (500, 502, 503, 504)
  class ServerError < APIError; end

  # Raised when there's a network/connection error
  class ConnectionError < Error; end

  # Raised when a request times out
  class TimeoutError < ConnectionError; end

  # Maps HTTP status codes to error classes
  HTTP_STATUS_ERRORS = {
    400 => BadRequestError,
    401 => AuthenticationError,
    403 => ForbiddenError,
    404 => NotFoundError,
    422 => UnprocessableEntityError,
    429 => RateLimitError,
    500 => ServerError,
    502 => ServerError,
    503 => ServerError,
    504 => ServerError
  }.freeze
end
