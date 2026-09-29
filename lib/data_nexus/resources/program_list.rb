# frozen_string_literal: true

module DataNexus
  module Resources
    # Resource for listing the programs visible to the API key
    #
    # For operations on a specific program, use `programs("uuid")`.
    #
    # @example List programs
    #   collection = client.programs.list
    #   collection.data.each { |program| puts "#{program[:id]} #{program[:name]}" }
    #
    # @example Look up a program ID by name
    #   program = client.programs.list.data.find { |p| p[:name] == "Example Program" }
    #   raise "Program not found" unless program
    #   client.programs(program[:id]).search_members(born_on: "1976-07-04", employee_id: "ABC123")
    #
    class ProgramList
      # @return [Connection] The HTTP connection
      attr_reader :connection

      # Initialize a new ProgramList resource
      #
      # @param connection [Connection] The HTTP connection
      def initialize(connection)
        @connection = connection
      end

      # List programs, sorted by name
      #
      # Note: the API currently returns at most 25 programs and ignores the
      # paging parameters below.
      #
      # @param after [String, nil] Cursor for next group of records
      # @param before [String, nil] Cursor for previous group of records
      # @param first [Integer, nil] Number of records to fetch after cursor
      # @param last [Integer, nil] Number of records to fetch before cursor
      #
      # @return [Collection] Collection of programs, each with :id and :name
      #
      # @example Basic listing
      #   collection = client.programs.list
      #   collection.data.each { |p| puts p[:name] }
      #
      # @example Iterate over every program returned
      #   client.programs.list.each { |p| puts p[:name] }
      def list(**params)
        allowed_params = %i[after before first last]

        query_params = params.slice(*allowed_params).compact
        response = connection.get(base_path, query_params)
        Collection.new(response, resource: self, params: query_params)
      end

      private

      # Base path for programs endpoints
      #
      # @return [String]
      def base_path
        '/api/programs'
      end
    end
  end
end
