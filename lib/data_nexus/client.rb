# frozen_string_literal: true

require_relative 'configuration'
require_relative 'connection'
require_relative 'resources/programs'

module DataNexus
  # Main client for interacting with the DataNexus API
  #
  # @example Create a client with explicit configuration
  #   client = DataNexus::Client.new(api_key: "your_api_key")
  #
  # @example Create a client with a configuration object
  #   config = DataNexus::Configuration.new(api_key: "your_api_key")
  #   client = DataNexus::Client.new(config: config)
  #
  # @example Access program members
  #   client.programs("program-uuid").members.list
  #   client.programs("program-uuid").members.find("member-id")
  #
  class Client
    # @return [Configuration] The client configuration
    attr_reader :config

    # @return [Connection] The HTTP connection
    attr_reader :connection

    # Initialize a new Client
    #
    # @param api_key [String, nil] The API key for authentication
    # @param base_url [String, nil] The base URL for the API
    # @param timeout [Integer, nil] Request timeout in seconds
    # @param open_timeout [Integer, nil] Connection open timeout in seconds
    # @param config [Configuration, nil] A pre-built configuration object
    #
    # @raise [ConfigurationError] If no API key is provided
    def initialize(api_key: nil, base_url: nil, timeout: nil, open_timeout: nil, ssl_verify: nil, config: nil)
      @config = config || build_configuration(
        api_key: api_key,
        base_url: base_url,
        timeout: timeout,
        open_timeout: open_timeout,
        ssl_verify: ssl_verify
      )

      validate_configuration!

      @connection = Connection.new(@config)
    end

    # Access program-scoped resources
    #
    # @param program_id [String] The program UUID
    # @return [Resources::Programs] A program resource proxy
    #
    # @example
    #   client.programs("uuid").members.list
    def programs(program_id)
      Resources::Programs.new(connection, program_id)
    end

    private

    # Build a configuration from individual parameters
    #
    # @param api_key [String, nil]
    # @param base_url [String, nil]
    # @param timeout [Integer, nil]
    # @param open_timeout [Integer, nil]
    # @param ssl_verify [Boolean, nil]
    # @return [Configuration]
    def build_configuration(api_key:, base_url:, timeout:, open_timeout:, ssl_verify:)
      Configuration.new(
        api_key: api_key,
        base_url: base_url || Configuration::DEFAULT_BASE_URL,
        timeout: timeout || Configuration::DEFAULT_TIMEOUT,
        open_timeout: open_timeout || Configuration::DEFAULT_OPEN_TIMEOUT,
        ssl_verify: ssl_verify.nil? ? Configuration::DEFAULT_SSL_VERIFY : ssl_verify
      )
    end

    # Validate that the configuration is complete
    #
    # @raise [ConfigurationError] If the configuration is invalid
    def validate_configuration!
      return if @config.valid?

      raise ConfigurationError, 'API key is required. Pass api_key: or provide a configured Configuration object.'
    end
  end
end
