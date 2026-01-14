# frozen_string_literal: true

module DataNexus
  module Resources
    # Resource for managing members at the top level
    #
    # Provides methods for listing, finding, and updating members
    # without requiring a program scope.
    #
    # @example List members with filters
    #   client.members.list(
    #     first_name: "george",
    #     born_on: "1976-07-04"
    #   )
    #
    # @example Paginate through members
    #   collection = client.members.list(first: 50)
    #   collection.each_page { |page| process(page.data) }
    #
    # @example Find a specific member
    #   member = client.members.find("member-id")
    #
    class Members
      # @return [Connection] The HTTP connection
      attr_reader :connection

      # Initialize a new Members resource
      #
      # @param connection [Connection] The HTTP connection
      def initialize(connection)
        @connection = connection
      end

      # List members with optional filters
      #
      # @param after [String, nil] Cursor for next group of records
      # @param before [String, nil] Cursor for previous group of records
      # @param first [Integer, nil] Number of records to fetch after cursor
      # @param last [Integer, nil] Number of records to fetch before cursor
      # @param born_on [String, nil] Filter by date of birth (YYYY-MM-DD)
      # @param first_name [String, nil] Filter by first name
      # @param last_name [String, nil] Filter by last name
      # @param program_id [String, nil] Filter by program UUID (members eligible for program)
      # @param updated_since [String, nil] Filter by update time (ISO 8601 datetime)
      #
      # @return [Collection] Paginated collection of members
      #
      # @example Basic listing
      #   collection = client.members.list
      #   collection.data.each { |m| puts m[:first_name] }
      #
      # @example With filters
      #   collection = client.members.list(
      #     born_on: "1976-07-04",
      #     first_name: "george"
      #   )
      #
      # @example With pagination
      #   collection = client.members.list(first: 50, after: "cursor")
      #
      # @example Filter by program eligibility
      #   collection = client.members.list(program_id: "uuid")
      #
      # @example Filter by update time
      #   collection = client.members.list(updated_since: "2024-01-01T00:00:00Z")
      def list(**params)
        allowed_params = %i[
          after before first last
          born_on first_name last_name
          program_id updated_since
        ]

        query_params = params.slice(*allowed_params).compact
        response = connection.get(base_path, query_params)
        Collection.new(response, resource: self, params: query_params)
      end

      # Find a specific member by ID
      #
      # @param member_id [String] The member ID
      # @return [Hash] The member data
      #
      # @example
      #   member = client.members.find("member-id")
      #   puts member[:first_name]
      def find(member_id)
        response = connection.get("#{base_path}/#{member_id}")
        response[:data]
      end

      # Update a member's attributes
      #
      # @param member_id [String] The member ID
      # @param member [Hash] The member attributes to update
      # @return [Hash] Response containing :data with the updated member
      #
      # @example
      #   response = client.members.update("member-id",
      #     member: { phone_number: "+15551234567" }
      #   )
      #   updated_member = response[:data]
      def update(member_id, member:)
        body = { member: member }
        connection.patch("#{base_path}/#{member_id}", body)
      end

      private

      # Base path for members endpoints
      #
      # @return [String]
      def base_path
        '/api/members'
      end
    end
  end
end
