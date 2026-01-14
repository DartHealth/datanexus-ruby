# frozen_string_literal: true

require_relative 'member_consents'
require_relative 'member_enrollments'

module DataNexus
  module Resources
    # Resource for managing a specific member within a program context
    #
    # Provides methods for finding, updating, and accessing related resources
    # for a specific member.
    #
    # @example Find a member
    #   member = client.programs("program-uuid").members("member-id").find
    #
    # @example Update a member
    #   client.programs("program-uuid").members("member-id").update(
    #     member: { phone_number: "+15551234567" }
    #   )
    #
    # @example Get household members
    #   household = client.programs("program-uuid").members("member-id").household
    #
    # @example Access consents
    #   client.programs("program-uuid").members("member-id").consents.create(
    #     consent: { category: "sms", member_response: true, consent_details: {} }
    #   )
    #
    # @example Access enrollments
    #   client.programs("program-uuid").members("member-id").enrollments.create(
    #     enrollment: { enrolled_at: "2024-01-01T00:00:00Z" }
    #   )
    #
    class ProgramMember
      # @return [Connection] The HTTP connection
      attr_reader :connection

      # @return [String] The program UUID
      attr_reader :program_id

      # @return [String] The member ID
      attr_reader :member_id

      # Initialize a new ProgramMember resource
      #
      # @param connection [Connection] The HTTP connection
      # @param program_id [String] The program UUID
      # @param member_id [String] The member ID
      def initialize(connection, program_id, member_id)
        @connection = connection
        @program_id = program_id
        @member_id = member_id
      end

      # Find this member
      #
      # @return [Hash] The member data
      #
      # @example
      #   member = client.programs("uuid").members("member-id").find
      #   puts member[:first_name]
      def find
        response = connection.get("#{base_path}/#{member_id}")
        response[:data]
      end

      # Update this member's attributes
      #
      # @param member [Hash] The member attributes to update
      # @return [Hash] Response containing :data with the updated member
      #
      # @example
      #   response = client.programs("uuid").members("member-id").update(
      #     member: { phone_number: "+15551234567" }
      #   )
      #   updated_member = response[:data]
      def update(member:)
        body = { member: member }
        connection.patch("#{base_path}/#{member_id}", body)
      end

      # Get household members for this member
      #
      # @return [Array<Hash>] Array of household member data
      #
      # @example
      #   household = client.programs("uuid").members("member-id").household
      #   household.each { |m| puts "#{m[:first_name]} - #{m[:relationship_type]}" }
      def household
        response = connection.get("#{base_path}/#{member_id}/household")
        response[:data]
      end

      # Access consents for this member
      #
      # @return [MemberConsents] The member consents resource
      #
      # @example Create a consent
      #   client.programs("uuid").members("member-id").consents.create(
      #     consent: { category: "sms", member_response: true, consent_details: {} }
      #   )
      #
      # @example Find a consent
      #   client.programs("uuid").members("member-id").consents.find(123)
      def consents
        MemberConsents.new(connection, member_id, program_id)
      end

      # Access enrollments for this member
      #
      # @return [MemberEnrollments] The member enrollments resource
      #
      # @example Create an enrollment
      #   client.programs("uuid").members("member-id").enrollments.create(
      #     enrollment: { enrolled_at: "2024-01-01T00:00:00Z" }
      #   )
      #
      # @example Find an enrollment
      #   client.programs("uuid").members("member-id").enrollments.find(123)
      def enrollments
        MemberEnrollments.new(connection, member_id, program_id)
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
