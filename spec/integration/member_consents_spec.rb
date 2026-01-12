# frozen_string_literal: true

RSpec.describe 'Member Consents', :vcr do
  let(:api_key) { ENV.fetch('DATANEXUS_API_KEY', 'test-api-key') }
  let(:base_url) { ENV.fetch('DATANEXUS_BASE_URL', 'http://localhost:4000') }
  let(:ssl_verify) { ENV.fetch('DATANEXUS_SSL_VERIFY', 'true') == 'true' }
  let(:program_id) { ENV.fetch('DATANEXUS_TEST_PROGRAM_ID', 'test-program-id') }
  let(:member_id) { ENV.fetch('DATANEXUS_TEST_MEMBER_ID', 'test-member-id') }
  let(:client) { DataNexus::Client.new(api_key: api_key, base_url: base_url, ssl_verify: ssl_verify) }

  describe 'creating a consent' do
    it 'returns the created consent', vcr: { cassette_name: 'member_consents/create' } do
      response = client.programs(program_id).members.consents(member_id).create(
        consent: {
          category: 'sms',
          member_response: true,
          consent_details: { sms_phone_number: '+15558675309' }
        }
      )

      expect(response).to be_a(Hash)
      expect(response).to have_key(:data)
      expect(response[:data][:category]).to eq('sms')
      expect(response[:data][:member_response]).to be true
    end

    it 'auto-injects the program_id', vcr: { cassette_name: 'member_consents/create' } do
      response = client.programs(program_id).members.consents(member_id).create(
        consent: {
          category: 'sms',
          member_response: true,
          consent_details: {}
        }
      )

      expect(response[:data][:program_id]).to eq(program_id)
    end
  end

  describe 'finding a consent' do
    let(:consent_id) { ENV.fetch('DATANEXUS_TEST_CONSENT_ID', 'test-consent-id') }

    it 'returns the consent data', vcr: { cassette_name: 'member_consents/find' } do
      consent = client.programs(program_id).members.consents(member_id).find(consent_id)

      expect(consent).to be_a(Hash)
      expect(consent).to have_key(:id)
      expect(consent).to have_key(:category)
      expect(consent).to have_key(:member_response)
      expect(consent).to have_key(:consent_details)
    end
  end

  describe 'updating a consent' do
    let(:consent_id) { ENV.fetch('DATANEXUS_TEST_CONSENT_ID', 'test-consent-id') }

    it 'returns the updated consent', vcr: { cassette_name: 'member_consents/update' } do
      response = client.programs(program_id).members.consents(member_id).update(
        consent_id,
        consent: { member_response: false }
      )

      expect(response).to be_a(Hash)
      expect(response).to have_key(:data)
    end
  end

  describe 'deleting a consent' do
    let(:consent_id) { ENV.fetch('DATANEXUS_TEST_CONSENT_ID', 'test-consent-id') }

    it 'returns an empty response', vcr: { cassette_name: 'member_consents/delete' } do
      response = client.programs(program_id).members.consents(member_id).delete(consent_id)

      expect(response).to eq({})
    end
  end
end
