# frozen_string_literal: true

module DataNexus
  module Resources
    # Resource for listing program members
    #
    # Provides methods for listing and searching members within a specific program.
    # For operations on a specific member, use `programs("uuid").members("member-id")`.
    #
    # @example List members with filters
    #   client.programs("uuid").members.list(
    #     first_name: "george",
    #     born_on: "1976-07-04"
    #   )
    #
    # @example Paginate through members
    #   collection = client.programs("uuid").members.list(first: 50)
    #   collection.each_page { |page| process(page.data) }
    #
    class ProgramMembers
      # @return [Connection] The HTTP connection
      attr_reader :connection

      # @return [String] The program UUID
      attr_reader :program_id

      # Initialize a new ProgramMembers resource
      #
      # @param connection [Connection] The HTTP connection
      # @param program_id [String] The program UUID
      def initialize(connection, program_id)
        @connection = connection
        @program_id = program_id
      end

      # List program members with optional filters
      #
      # @param first_name [String, nil] Filter by exact first name
      # @param first_name_prefix [String, nil] Filter by first name prefix (first initial)
      # @param last_name [String, nil] Filter by exact last name
      # @param last_name_prefix [String, nil] Filter by last name prefix (min 3 chars)
      # @param born_on [String, nil] Filter by date of birth (YYYY-MM-DD)
      # @param employee_id [String, nil] Filter by employee ID
      #
      # @return [Collection] Paginated collection of members
      #
      # @example Basic listing
      #   collection = client.programs("uuid").members.list
      #   collection.data.each { |m| puts m[:first_name] }
      #
      # @example With filters
      #   collection = client.programs("uuid").members.list(
      #     born_on: "1976-07-04",
      #     last_name_prefix: "was"
      #   )
      def list(**params)
        allowed_params = %i[
          first_name first_name_prefix
          last_name last_name_prefix
          born_on employee_id
        ]

        query_params = params.slice(*allowed_params).compact
        response = connection.get(base_path, query_params)
        Collection.new(response, resource: self, params: query_params)
      end

      private

      # Base path for program members endpoints
      #
      # @return [String]
      def base_path
        "/api/programs/#{program_id}/members"
      end
    end
  end
end
