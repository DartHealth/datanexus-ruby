# frozen_string_literal: true

module DataNexus
  module Resources
    # Resource for managing member enrollments
    #
    # Provides methods for creating, finding, updating, and deleting
    # enrollments for a specific member.
    #
    # @example Create an enrollment
    #   client.programs("program-uuid").members("member-id").enrollments.create(
    #     enrollment: {
    #       enrolled_at: "2024-01-01T00:00:00Z",
    #       expires_at: "2025-01-01T00:00:00Z"
    #     }
    #   )
    #
    # @example Find an enrollment
    #   enrollment = client.programs("program-uuid").members("member-id").enrollments.find(123)
    #
    # @example Update an enrollment
    #   client.programs("program-uuid").members("member-id").enrollments.update(123,
    #     enrollment: { expires_at: "2026-01-01T00:00:00Z" }
    #   )
    #
    # @example Delete an enrollment
    #   client.programs("program-uuid").members("member-id").enrollments.delete(123)
    #
    class MemberEnrollments
      # @return [Connection] The HTTP connection
      attr_reader :connection

      # @return [String] The member ID
      attr_reader :member_id

      # @return [String] The program UUID
      attr_reader :program_id

      # Initialize a new MemberEnrollments resource
      #
      # @param connection [Connection] The HTTP connection
      # @param member_id [String] The member ID
      # @param program_id [String] The program UUID
      def initialize(connection, member_id, program_id)
        @connection = connection
        @member_id = member_id
        @program_id = program_id
      end

      # Create a new enrollment for the member
      #
      # @param enrollment [Hash] The enrollment attributes
      # @option enrollment [String] :enrolled_at The datetime of enrollment (required)
      # @option enrollment [String] :expires_at The datetime when enrollment expires (optional)
      # @return [Hash] Response containing :data with the created enrollment
      #
      # @note The program_id is automatically injected from the resource chain
      #
      # @example
      #   response = client.programs("program-uuid").members("member-id").enrollments.create(
      #     enrollment: {
      #       enrolled_at: "2024-01-01T00:00:00Z"
      #     }
      #   )
      #   created_enrollment = response[:data]
      def create(enrollment:)
        enrollment_with_program = enrollment.merge(program_id: program_id)
        body = { enrollment: enrollment_with_program }
        connection.post(base_path, body)
      end

      # Find a specific enrollment by ID
      #
      # @param enrollment_id [Integer, String] The enrollment ID
      # @return [Hash] The enrollment data
      #
      # @example
      #   enrollment = client.programs("program-uuid").members("member-id").enrollments.find(123)
      #   puts enrollment[:program_id]
      def find(enrollment_id)
        response = connection.get("#{base_path}/#{enrollment_id}")
        response[:data]
      end

      # Update an enrollment's attributes
      #
      # @param enrollment_id [Integer, String] The enrollment ID
      # @param enrollment [Hash] The enrollment attributes to update
      # @return [Hash] Response containing :data with the updated enrollment
      #
      # @example
      #   response = client.programs("program-uuid").members("member-id").enrollments.update(123,
      #     enrollment: { expires_at: "2026-01-01T00:00:00Z" }
      #   )
      #   updated_enrollment = response[:data]
      def update(enrollment_id, enrollment:)
        body = { enrollment: enrollment }
        connection.patch("#{base_path}/#{enrollment_id}", body)
      end

      # Delete an enrollment
      #
      # @param enrollment_id [Integer, String] The enrollment ID
      # @return [Hash] Empty hash on success (204 No Content)
      #
      # @example
      #   client.programs("program-uuid").members("member-id").enrollments.delete(123)
      def delete(enrollment_id)
        connection.delete("#{base_path}/#{enrollment_id}")
      end

      private

      # Base path for member enrollments endpoints
      #
      # @return [String]
      def base_path
        "/api/members/#{member_id}/enrollments"
      end
    end
  end
end
