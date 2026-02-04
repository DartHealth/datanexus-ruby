# frozen_string_literal: true

require_relative 'program_member'
require_relative 'program_members'

module DataNexus
  module Resources
    # Proxy for program-scoped resources
    #
    # This class provides access to resources that are scoped to a specific program,
    # such as members, consents, and enrollments.
    #
    # @example List program members
    #   client.programs("program-uuid").members.list
    #
    # @example Access a specific member
    #   client.programs("program-uuid").members("member-id").find
    #   client.programs("program-uuid").members("member-id").update(member: { phone_number: "..." })
    #   client.programs("program-uuid").members("member-id").consents.create(...)
    #   client.programs("program-uuid").members("member-id").enrollments.create(...)
    #
    # @example Search for members
    #   client.programs("program-uuid").search_members(born_on: "1976-07-04", employee_id: "ABC123")
    #
    class Programs
      VALID_SEARCH_COMBINATIONS = [
        %i[born_on first_name last_name employee_id],
        %i[born_on first_name last_name],
        %i[born_on first_name_prefix last_name_prefix employee_id],
        %i[born_on first_name_prefix last_name_prefix],
        %i[born_on employee_id]
      ].freeze

      # @return [Connection] The HTTP connection
      attr_reader :connection

      # @return [String] The program UUID
      attr_reader :program_id

      # Initialize a new Programs resource proxy
      #
      # @param connection [Connection] The HTTP connection
      # @param program_id [String] The program UUID
      def initialize(connection, program_id)
        @connection = connection
        @program_id = program_id
      end

      # Access program members
      #
      # When called without an argument, returns a resource for listing members.
      # When called with a member_id, returns a resource for that specific member.
      #
      # @param member_id [String, nil] The member ID (optional)
      # @return [ProgramMembers] When no member_id provided - for listing members
      # @return [ProgramMember] When member_id provided - for member-specific operations
      #
      # @example List members
      #   client.programs("uuid").members.list
      #
      # @example Access a specific member
      #   client.programs("uuid").members("member-id").find
      #
      # @example Update a member
      #   client.programs("uuid").members("member-id").update(member: { first_name: "George" })
      #
      # @example Access member consents
      #   client.programs("uuid").members("member-id").consents.create(...)
      #
      # @example Access member enrollments
      #   client.programs("uuid").members("member-id").enrollments.create(...)
      def members(member_id = nil)
        if member_id
          ProgramMember.new(connection, program_id, member_id)
        else
          ProgramMembers.new(connection, program_id)
        end
      end

      # Search for members within this program
      #
      # Returns a bounded result set (max 10 results). Use `more_results` to
      # determine if additional matches exist beyond what was returned.
      #
      # Valid parameter combinations:
      # - born_on, first_name, last_name, employee_id
      # - born_on, first_name, last_name
      # - born_on, first_name_prefix, last_name_prefix, employee_id
      # - born_on, first_name_prefix, last_name_prefix
      # - born_on, employee_id
      #
      # @param born_on [String] Date of birth (YYYY-MM-DD) - required for all searches
      # @param first_name [String, nil] Exact first name match
      # @param first_name_prefix [String, nil] First name prefix (min 1 char)
      # @param last_name [String, nil] Exact last name match
      # @param last_name_prefix [String, nil] Last name prefix (min 3 chars)
      # @param employee_id [String, nil] Employee ID
      #
      # @return [Hash] Response with :data (Array) and :more_results (Boolean)
      #
      # @raise [ArgumentError] If params don't match a valid search combination
      #
      # @example Search by name and DOB
      #   client.programs("uuid").search_members(
      #     born_on: "1976-07-04",
      #     first_name: "george",
      #     last_name: "washington"
      #   )
      #
      # @example Search by prefix and DOB
      #   client.programs("uuid").search_members(
      #     born_on: "1976-07-04",
      #     first_name_prefix: "g",
      #     last_name_prefix: "was"
      #   )
      #
      # @example Search by employee ID and DOB
      #   client.programs("uuid").search_members(
      #     born_on: "1976-07-04",
      #     employee_id: "ABC1234"
      #   )
      def search_members(**params)
        validate_search_params!(params)

        connection.post("/api/programs/#{program_id}/members/search", params)
      end

      private

      def validate_search_params!(params)
        provided_keys = params.keys.sort

        return if VALID_SEARCH_COMBINATIONS.any? { |combo| combo.sort == provided_keys }

        raise ArgumentError, invalid_search_params_message(provided_keys)
      end

      def invalid_search_params_message(provided_keys)
        valid_combos = VALID_SEARCH_COMBINATIONS.map { |c| c.join(', ') }.join("\n  - ")

        "Invalid search parameter combination: #{provided_keys.join(', ')}. " \
          "Valid combinations are:\n  - #{valid_combos}"
      end
    end
  end
end
