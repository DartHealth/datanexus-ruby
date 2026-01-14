# frozen_string_literal: true

RSpec.describe 'Members', :vcr do
  let(:api_key) { ENV.fetch('DATANEXUS_API_KEY', 'test-api-key') }
  let(:base_url) { ENV.fetch('DATANEXUS_BASE_URL', 'http://localhost:4000') }
  let(:ssl_verify) { ENV.fetch('DATANEXUS_SSL_VERIFY', 'true') == 'true' }
  let(:client) { DataNexus::Client.new(api_key: api_key, base_url: base_url, ssl_verify: ssl_verify) }

  describe 'listing members' do
    it 'returns a collection', vcr: { cassette_name: 'members/list' } do
      collection = client.members.list

      expect(collection).to be_a(DataNexus::Collection)
      expect(collection.data).to be_an(Array)
    end

    it 'includes pagination cursors', vcr: { cassette_name: 'members/list' } do
      collection = client.members.list

      # Cursors may be nil if there are no results, but should respond to the methods
      expect(collection).to respond_to(:start_cursor)
      expect(collection).to respond_to(:end_cursor)
    end

    it 'supports filtering by name', vcr: { cassette_name: 'members/list_by_name' } do
      collection = client.members.list(
        first_name: 'Test',
        last_name: 'User'
      )

      expect(collection).to be_a(DataNexus::Collection)
      expect(collection.data).to be_an(Array)
    end

    it 'supports filtering by born_on', vcr: { cassette_name: 'members/list_by_born_on' } do
      test_born_on = ENV.fetch('DATANEXUS_TEST_BORN_ON', '1970-01-01')
      collection = client.members.list(born_on: test_born_on)

      expect(collection).to be_a(DataNexus::Collection)
      expect(collection.data).to be_an(Array)
    end

    it 'supports filtering by program_id', vcr: { cassette_name: 'members/list_by_program' } do
      program_id = ENV.fetch('DATANEXUS_TEST_PROGRAM_ID', 'test-program-id')
      collection = client.members.list(program_id: program_id)

      expect(collection).to be_a(DataNexus::Collection)
      expect(collection.data).to be_an(Array)
    end

    it 'supports filtering by updated_since', vcr: { cassette_name: 'members/list_by_updated_since' } do
      collection = client.members.list(updated_since: '2020-01-01T00:00:00Z')

      expect(collection).to be_a(DataNexus::Collection)
      expect(collection.data).to be_an(Array)
    end

    it 'supports pagination parameters', vcr: { cassette_name: 'members/list_paginated' } do
      collection = client.members.list(first: 10)

      expect(collection).to be_a(DataNexus::Collection)
      expect(collection.data).to be_an(Array)
    end
  end

  describe 'finding a member' do
    let(:member_id) { ENV.fetch('DATANEXUS_TEST_MEMBER_ID', 'test-member-id') }

    it 'returns the member data', vcr: { cassette_name: 'members/find' } do
      member = client.members.find(member_id)

      expect(member).to be_a(Hash)
      expect(member).to have_key(:id)
      expect(member).to have_key(:first_name)
      expect(member).to have_key(:last_name)
    end
  end

  describe 'updating a member' do
    let(:member_id) { ENV.fetch('DATANEXUS_TEST_MEMBER_ID', 'test-member-id') }

    it 'returns the updated member', vcr: { cassette_name: 'members/update' } do
      response = client.members.update(
        member_id,
        member: { phone_number: '+15551234567' }
      )

      expect(response).to be_a(Hash)
      expect(response).to have_key(:data)
    end
  end
end
