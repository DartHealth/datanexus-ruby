# frozen_string_literal: true

RSpec.describe DataNexus::Resources::ProgramMembers do
  let(:base_url) { 'https://datanexus.test' }
  let(:client) { DataNexus::Client.new(api_key: 'test-api-key', base_url: base_url) }
  let(:members_url) { "#{base_url}/api/programs/program-1/members" }

  # The API returns program member lists as a single page that still carries a cursor
  let(:page) do
    {
      data: [{ id: 'member-1', first_name: 'Test', last_name: 'Member' }],
      start_cursor: 'cursor-1',
      end_cursor: 'cursor-1'
    }
  end

  before do
    stub_request(:get, members_url)
      .with(query: hash_including({}))
      .to_return(status: 200, body: page.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe '#list' do
    it 'stops iterating after the single page the API returns' do
      # Bounded so a regression fails instead of looping forever
      pages = client.programs('program-1').members.list(born_on: '1980-01-15', employee_id: 'EMP123')
                    .each_page.first(3)

      expect(pages.size).to eq(1)
    end

    it 'never sends a paging cursor, which the API rejects' do
      client.programs('program-1').members.list(born_on: '1980-01-15', employee_id: 'EMP123').each_page.first(3)

      expect(a_request(:get, /#{Regexp.escape(members_url)}\?.*\bafter=/)).not_to have_been_made
    end
  end
end
