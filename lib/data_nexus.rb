# frozen_string_literal: true

require_relative 'data_nexus/version'
require_relative 'data_nexus/errors'
require_relative 'data_nexus/configuration'
require_relative 'data_nexus/connection'
require_relative 'data_nexus/client'
require_relative 'data_nexus/collection'
require_relative 'data_nexus/resources/programs'
require_relative 'data_nexus/resources/program_members'

# Ruby client library for the DataNexus API
#
# @example Configure and use the client
#   client = DataNexus::Client.new(api_key: "your_api_key")
#   members = client.programs("program-uuid").members.list
#
module DataNexus
  class << self
    # Global configuration instance
    #
    # @return [Configuration]
    attr_writer :configuration

    # Get the global configuration, initializing if needed
    #
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure the gem globally
    #
    # @example
    #   DataNexus.configure do |config|
    #     config.api_key = "your_api_key"
    #     config.base_url = "https://datanexus.darthealth.com"
    #   end
    #
    # @yield [Configuration]
    def configure
      yield(configuration)
    end

    # Reset the global configuration
    #
    # @return [Configuration] A fresh configuration instance
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
