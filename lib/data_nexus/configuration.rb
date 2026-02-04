# frozen_string_literal: true

module DataNexus
  # Configuration class for storing API credentials and settings
  #
  # @example Configure the client globally
  #   DataNexus.configure do |config|
  #     config.api_key = "your_api_key"
  #     config.base_url = "https://datanexus.darthealth.com"
  #   end
  #
  # @example Create a configuration instance
  #   config = DataNexus::Configuration.new(
  #     api_key: "your_api_key",
  #     base_url: "https://datanexus.darthealth.com"
  #   )
  #
  class Configuration
    # @return [String, nil] The API key for authentication
    attr_accessor :api_key

    # @return [String] The base URL for the DataNexus API
    attr_accessor :base_url

    # @return [Integer] Request timeout in seconds
    attr_accessor :timeout

    # @return [Integer] Connection open timeout in seconds
    attr_accessor :open_timeout

    # @return [Boolean] Whether to verify SSL certificates
    attr_accessor :ssl_verify

    # Default base URL for the DataNexus API
    DEFAULT_BASE_URL = 'https://datanexus.darthealth.com'

    # Default request timeout in seconds
    DEFAULT_TIMEOUT = 30

    # Default connection open timeout in seconds
    DEFAULT_OPEN_TIMEOUT = 10

    # Default SSL verification setting
    DEFAULT_SSL_VERIFY = true

    # Initialize a new Configuration instance
    #
    # @param api_key [String, nil] The API key for authentication
    # @param base_url [String] The base URL for the API
    # @param timeout [Integer] Request timeout in seconds
    # @param open_timeout [Integer] Connection open timeout in seconds
    # @param ssl_verify [Boolean] Whether to verify SSL certificates (set to false for self-signed certs)
    def initialize(
      api_key: nil,
      base_url: DEFAULT_BASE_URL,
      timeout: DEFAULT_TIMEOUT,
      open_timeout: DEFAULT_OPEN_TIMEOUT,
      ssl_verify: DEFAULT_SSL_VERIFY
    )
      @api_key = api_key
      @base_url = base_url
      @timeout = timeout
      @open_timeout = open_timeout
      @ssl_verify = ssl_verify
    end

    # Check if the configuration has valid credentials
    #
    # @return [Boolean] true if api_key is present
    def valid?
      !api_key.nil? && !api_key.empty?
    end
  end
end
