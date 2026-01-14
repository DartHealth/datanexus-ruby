# frozen_string_literal: true

RSpec.describe 'Member Enrollments', :vcr, order: :defined do
  let(:api_key) { ENV.fetch('DATANEXUS_API_KEY', 'test-api-key') }
  let(:base_url) { ENV.fetch('DATANEXUS_BASE_URL', 'http://localhost:4000') }
  let(:ssl_verify) { ENV.fetch('DATANEXUS_SSL_VERIFY', 'true') == 'true' }
  let(:program_id) { ENV.fetch('DATANEXUS_TEST_PROGRAM_ID', 'test-program-id') }
  let(:member_id) { ENV.fetch('DATANEXUS_TEST_MEMBER_ID', 'test-member-id') }
  let(:client) { DataNexus::Client.new(api_key: api_key, base_url: base_url, ssl_verify: ssl_verify) }

  describe 'creating an enrollment' do
    it 'returns the created enrollment', vcr: { cassette_name: 'member_enrollments/create' } do
      response = client.programs(program_id).members(member_id).enrollments.create(
        enrollment: {
          enrolled_at: '2024-01-01T00:00:00Z',
          expires_at: '2025-01-01T00:00:00Z'
        }
      )

      expect(response).to be_a(Hash)
      expect(response).to have_key(:data)
      expect(response[:data][:enrolled_at]).not_to be_nil
    end

    it 'auto-injects the program_id', vcr: { cassette_name: 'member_enrollments/create' } do
      response = client.programs(program_id).members(member_id).enrollments.create(
        enrollment: {
          enrolled_at: '2024-01-01T00:00:00Z'
        }
      )

      expect(response[:data][:program_id]).to eq(program_id)
    end
  end

  describe 'finding an enrollment' do
    let(:enrollment_id) { ENV.fetch('DATANEXUS_TEST_ENROLLMENT_ID', 'test-enrollment-id') }

    it 'returns the enrollment data', vcr: { cassette_name: 'member_enrollments/find' } do
      enrollment = client.programs(program_id).members(member_id).enrollments.find(enrollment_id)

      expect(enrollment).to be_a(Hash)
      expect(enrollment).to have_key(:id)
      expect(enrollment).to have_key(:program_id)
      expect(enrollment).to have_key(:enrolled_at)
    end
  end

  describe 'updating an enrollment' do
    let(:enrollment_id) { ENV.fetch('DATANEXUS_TEST_ENROLLMENT_ID', 'test-enrollment-id') }

    it 'returns the updated enrollment', vcr: { cassette_name: 'member_enrollments/update' } do
      response = client.programs(program_id).members(member_id).enrollments.update(
        enrollment_id,
        enrollment: { expires_at: '2026-01-01T00:00:00Z' }
      )

      expect(response).to be_a(Hash)
      expect(response).to have_key(:data)
    end
  end

  describe 'deleting an enrollment' do
    let(:enrollment_id) { ENV.fetch('DATANEXUS_TEST_ENROLLMENT_ID', 'test-enrollment-id') }

    it 'returns an empty response', vcr: { cassette_name: 'member_enrollments/delete' } do
      response = client.programs(program_id).members(member_id).enrollments.delete(enrollment_id)

      expect(response).to eq({})
    end
  end
end
