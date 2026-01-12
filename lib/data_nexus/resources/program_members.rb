# frozen_string_literal: true

module DataNexus
  module Resources
    # Resource for managing program members
    #
    # Provides methods for listing, finding, updating, and retrieving
    # household information for members within a specific program.
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

      # Find a specific member by ID
      #
      # @param member_id [String] The member ID
      # @return [Hash] The member data
      #
      # @example
      #   member = client.programs("uuid").members.find("member-id")
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
      #   response = client.programs("uuid").members.update("member-id",
      #     member: { first_name: "George", last_name: "Washington" }
      #   )
      #   updated_member = response[:data]
      def update(member_id, member:)
        body = { member: member }
        connection.patch("#{base_path}/#{member_id}", body)
      end

      # Get household members for a specific member
      #
      # @param member_id [String] The member ID
      # @return [Collection] Paginated collection of household members
      #
      # @example
      #   household = client.programs("uuid").members.household("member-id")
      #   household.data.each { |m| puts "#{m[:first_name]} - #{m[:relationship_type]}" }
      def household(member_id)
        response = connection.get("#{base_path}/#{member_id}/household")
        Collection.new(response, resource: self, params: { member_id: member_id })
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
