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
    class Programs
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
    end
  end
end
