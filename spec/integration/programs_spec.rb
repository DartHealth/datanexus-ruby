# frozen_string_literal: true

RSpec.describe 'Programs', :vcr do
  let(:api_key) { ENV.fetch('DATANEXUS_API_KEY', 'test-api-key') }
  let(:base_url) { ENV.fetch('DATANEXUS_BASE_URL', 'http://localhost:4000') }
  let(:ssl_verify) { ENV.fetch('DATANEXUS_SSL_VERIFY', 'true') == 'true' }
  let(:client) { DataNexus::Client.new(api_key: api_key, base_url: base_url, ssl_verify: ssl_verify) }

  describe 'listing programs' do
    it 'returns a collection', vcr: { cassette_name: 'programs/list' } do
      collection = client.programs.list

      expect(collection).to be_a(DataNexus::Collection)
      expect(collection.data).to be_an(Array)
    end

    it 'returns each program with an id and a name', vcr: { cassette_name: 'programs/list' } do
      programs = client.programs.list.data

      expect(programs).to be_any.and all(include(:id, :name))
    end

    it 'includes the test program', vcr: { cassette_name: 'programs/list' } do
      program_id = ENV.fetch('DATANEXUS_TEST_PROGRAM_ID', 'test-program-id')
      ids = client.programs.list.data.map { |program| program[:id] }

      expect(ids).to include(program_id)
    end
  end
end
