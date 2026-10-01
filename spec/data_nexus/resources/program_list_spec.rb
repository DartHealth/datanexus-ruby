# frozen_string_literal: true

RSpec.describe DataNexus::Resources::ProgramList do
  let(:base_url) { 'https://datanexus.test' }
  let(:client) { DataNexus::Client.new(api_key: 'test-api-key', base_url: base_url) }

  let(:first_page) do
    {
      data: [
        { id: 'program-1', name: 'Another Program' },
        { id: 'program-2', name: 'Example Program' }
      ],
      start_cursor: 'cursor-1',
      end_cursor: 'cursor-2'
    }
  end

  let(:last_page) do
    {
      data: [{ id: 'program-3', name: 'Last Program' }],
      start_cursor: 'cursor-3',
      end_cursor: 'cursor-3',
      has_next_page: false
    }
  end

  def stub_programs(query, body)
    stub_request(:get, "#{base_url}/api/programs")
      .with(query: query)
      .to_return(status: 200, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe 'Client#programs' do
    it 'returns a program list when called without a program ID' do
      expect(client.programs).to be_a(described_class)
    end

    it 'still returns a single-program proxy when called with a program ID' do
      expect(client.programs('program-1')).to be_a(DataNexus::Resources::Programs)
    end
  end

  describe '#list' do
    it 'returns a collection of the programs the API key can see' do
      stub_programs({}, first_page)

      collection = client.programs.list

      expect(collection).to be_a(DataNexus::Collection)
        .and have_attributes(data: first_page[:data], end_cursor: 'cursor-2')
    end

    it 'sends pagination params and drops unknown ones' do
      stub = stub_programs({ 'first' => '10', 'after' => 'cursor-0' }, first_page)

      client.programs.list(first: 10, after: 'cursor-0', bogus: 'x')

      expect(stub).to have_been_requested
    end

    it 'filters by name' do
      stub = stub_programs({ 'name' => 'Example Program' }, first_page)

      client.programs.list(name: 'Example Program')

      expect(stub).to have_been_requested
    end

    it 'follows cursors across pages and stops when has_next_page is false' do
      stub_programs({}, first_page.merge(has_next_page: true))
      stub_programs({ 'after' => 'cursor-2' }, last_page)

      names = client.programs.list.each.map { |p| p[:name] }

      expect(names).to eq(['Another Program', 'Example Program', 'Last Program'])
    end
  end
end
