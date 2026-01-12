# frozen_string_literal: true

require_relative 'program_members'

module DataNexus
  module Resources
    # Proxy for program-scoped resources
    #
    # This class provides access to resources that are scoped to a specific program,
    # such as members, consents, and enrollments.
    #
    # @example Access program members
    #   client.programs("program-uuid").members.list
    #   client.programs("program-uuid").members.find("member-id")
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
      # @return [ProgramMembers] The program members resource
      #
      # @example List members
      #   client.programs("uuid").members.list
      #
      # @example Find a member
      #   client.programs("uuid").members.find("member-id")
      #
      # @example Update a member
      #   client.programs("uuid").members.update("member-id", member: { first_name: "George" })
      #
      # @example Get household members
      #   client.programs("uuid").members.household("member-id")
      def members
        @members ||= ProgramMembers.new(connection, program_id)
      end
    end
  end
end
