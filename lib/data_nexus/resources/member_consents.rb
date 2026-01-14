# frozen_string_literal: true

module DataNexus
  module Resources
    # Resource for managing member consents
    #
    # Provides methods for creating, finding, updating, and deleting
    # consents for a specific member.
    #
    # @example Create a consent
    #   client.programs("uuid").members("member-id").consents.create(
    #     consent: {
    #       category: "sms",
    #       member_response: true,
    #       consent_details: { sms_phone_number: "+15558675309" }
    #     }
    #   )
    #
    # @example Find a consent
    #   consent = client.programs("uuid").members("member-id").consents.find(123)
    #
    # @example Update a consent
    #   client.programs("uuid").members("member-id").consents.update(123,
    #     consent: { member_response: false }
    #   )
    #
    # @example Delete a consent
    #   client.programs("uuid").members("member-id").consents.delete(123)
    #
    class MemberConsents
      # @return [Connection] The HTTP connection
      attr_reader :connection

      # @return [String] The member ID
      attr_reader :member_id

      # @return [String] The program UUID
      attr_reader :program_id

      # Initialize a new MemberConsents resource
      #
      # @param connection [Connection] The HTTP connection
      # @param member_id [String] The member ID
      # @param program_id [String] The program UUID
      def initialize(connection, member_id, program_id)
        @connection = connection
        @member_id = member_id
        @program_id = program_id
      end

      # Create a new consent for the member
      #
      # @param consent [Hash] The consent attributes
      # @option consent [String] :category The consent category (required)
      # @option consent [Hash] :consent_details Additional consent details (required, can be empty)
      # @option consent [String] :consented_at The datetime of consent (optional)
      # @option consent [Boolean] :member_response Whether member agreed (optional, default: false)
      # @return [Hash] Response containing :data with the created consent
      #
      # @example
      #   response = client.programs("uuid").members("member-id").consents.create(
      #     consent: {
      #       category: "sms",
      #       member_response: true,
      #       consent_details: { sms_phone_number: "+15558675309" }
      #     }
      #   )
      #   created_consent = response[:data]
      def create(consent:)
        consent_with_program = consent.merge(program_id: program_id)
        body = { consent: consent_with_program }
        connection.post(base_path, body)
      end

      # Find a specific consent by ID
      #
      # @param consent_id [Integer, String] The consent ID
      # @return [Hash] The consent data
      #
      # @example
      #   consent = client.programs("uuid").members("member-id").consents.find(123)
      #   puts consent[:category]
      def find(consent_id)
        response = connection.get("#{base_path}/#{consent_id}")
        response[:data]
      end

      # Update a consent's attributes
      #
      # @param consent_id [Integer, String] The consent ID
      # @param consent [Hash] The consent attributes to update
      # @return [Hash] Response containing :data with the updated consent
      #
      # @example
      #   response = client.programs("uuid").members("member-id").consents.update(123,
      #     consent: { member_response: false }
      #   )
      #   updated_consent = response[:data]
      def update(consent_id, consent:)
        body = { consent: consent }
        connection.patch("#{base_path}/#{consent_id}", body)
      end

      # Delete a consent
      #
      # @param consent_id [Integer, String] The consent ID
      # @return [Hash] Empty hash on success (204 No Content)
      #
      # @example
      #   client.programs("uuid").members("member-id").consents.delete(123)
      def delete(consent_id)
        connection.delete("#{base_path}/#{consent_id}")
      end

      private

      # Base path for member consents endpoints
      #
      # @return [String]
      def base_path
        "/api/members/#{member_id}/consents"
      end
    end
  end
end
