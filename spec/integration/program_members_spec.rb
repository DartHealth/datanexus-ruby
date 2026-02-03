# frozen_string_literal: true

RSpec.describe 'Program Members', :vcr do
  let(:api_key) { ENV.fetch('DATANEXUS_API_KEY', 'test-api-key') }
  let(:base_url) { ENV.fetch('DATANEXUS_BASE_URL', 'http://localhost:4000') }
  let(:ssl_verify) { ENV.fetch('DATANEXUS_SSL_VERIFY', 'true') == 'true' }
  let(:program_id) { ENV.fetch('DATANEXUS_TEST_PROGRAM_ID', 'test-program-id') }
  let(:test_born_on) { ENV.fetch('DATANEXUS_TEST_BORN_ON', '1970-01-01') }
  let(:test_employee_id) { ENV.fetch('DATANEXUS_TEST_EMPLOYEE_ID', 'test-employee-id') }
  let(:client) { DataNexus::Client.new(api_key: api_key, base_url: base_url, ssl_verify: ssl_verify) }

  describe 'listing members' do
    it 'returns a collection with born_on and employee_id filter', vcr: { cassette_name: 'program_members/list' } do
      collection = client.programs(program_id).members.list(
        born_on: test_born_on,
        employee_id: test_employee_id
      )

      expect(collection).to be_a(DataNexus::Collection)
      expect(collection.data).to be_an(Array)
    end

    it 'includes pagination cursors', vcr: { cassette_name: 'program_members/list' } do
      collection = client.programs(program_id).members.list(
        born_on: test_born_on,
        employee_id: test_employee_id
      )

      expect(collection.start_cursor).not_to be_nil
      expect(collection.end_cursor).not_to be_nil
      expect(collection.next_page?).to be true
    end

    it 'supports filtering by name prefix', vcr: { cassette_name: 'program_members/list_filtered' } do
      collection = client.programs(program_id).members.list(
        born_on: test_born_on,
        first_name_prefix: 'J',
        last_name_prefix: 'Smi'
      )

      expect(collection).to be_a(DataNexus::Collection)
    end
  end

  describe 'finding a member' do
    let(:member_id) { ENV.fetch('DATANEXUS_TEST_MEMBER_ID', 'test-member-id') }

    it 'returns the member data', vcr: { cassette_name: 'program_members/find' } do
      member = client.programs(program_id).members(member_id).find

      expect(member).to be_a(Hash)
      expect(member).to have_key(:id)
    end
  end

  describe 'updating a member' do
    let(:member_id) { ENV.fetch('DATANEXUS_TEST_MEMBER_ID', 'test-member-id') }

    it 'returns the updated member', vcr: { cassette_name: 'program_members/update' } do
      response = client.programs(program_id).members(member_id).update(
        member: { phone_number: '+15551234567' }
      )

      expect(response).to be_a(Hash)
      expect(response).to have_key(:data)
    end
  end

  describe 'household members' do
    let(:member_id) { ENV.fetch('DATANEXUS_TEST_MEMBER_ID', 'test-member-id') }

    it 'returns household members', vcr: { cassette_name: 'program_members/household' } do
      household = client.programs(program_id).members(member_id).household

      expect(household).to be_an(Array)
    end
  end

  describe 'searching members' do
    it 'returns members matching employee_id and DOB', vcr: { cassette_name: 'program_members/search_employee_id' } do
      result = client.programs(program_id).search_members(
        born_on: test_born_on,
        employee_id: test_employee_id
      )

      expect(result).to be_a(Hash)
      expect(result[:data]).to be_an(Array)
      expect(result).to have_key(:more_results)
    end

    it 'returns members matching name and DOB', vcr: { cassette_name: 'program_members/search_name' } do
      result = client.programs(program_id).search_members(
        born_on: test_born_on,
        first_name: 'Betty Jo',
        last_name: 'Brown'
      )

      expect(result).to be_a(Hash)
      expect(result[:data]).to be_an(Array)
      expect(result).to have_key(:more_results)
    end

    it 'returns members matching name prefix and DOB', vcr: { cassette_name: 'program_members/search_prefix' } do
      result = client.programs(program_id).search_members(
        born_on: test_born_on,
        first_name_prefix: 'Bet',
        last_name_prefix: 'Bro'
      )

      expect(result).to be_a(Hash)
      expect(result[:data]).to be_an(Array)
      expect(result).to have_key(:more_results)
    end

    it 'raises ArgumentError for invalid parameter combinations' do
      expect {
        client.programs(program_id).search_members(
          born_on: test_born_on,
          first_name: 'George'
        )
      }.to raise_error(ArgumentError, /Invalid search parameter combination/)
    end

    it 'raises ArgumentError when mixing prefix and exact name params' do
      expect {
        client.programs(program_id).search_members(
          born_on: test_born_on,
          first_name: 'George',
          last_name_prefix: 'Was'
        )
      }.to raise_error(ArgumentError, /Invalid search parameter combination/)
    end

    it 'raises ArgumentError when born_on is missing' do
      expect {
        client.programs(program_id).search_members(
          employee_id: test_employee_id
        )
      }.to raise_error(ArgumentError, /Invalid search parameter combination/)
    end
  end
end
