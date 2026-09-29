# frozen_string_literal: true

RSpec.describe DataNexus::Resources::ProgramList do
  let(:base_url) { 'https://datanexus.test' }
  let(:client) { DataNexus::Client.new(api_key: 'test-api-key', base_url: base_url) }

  let(:page1) do
    {
      data: [
        { id: 'program-1', name: 'Another Program' },
        { id: 'program-2', name: 'Example Program' }
      ],
      start_cursor: 'cursor-1',
      end_cursor: 'cursor-2'
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
      stub_programs({}, page1)

      collection = client.programs.list

      expect(collection).to be_a(DataNexus::Collection).and have_attributes(data: page1[:data], end_cursor: 'cursor-2')
    end

    it 'sends pagination params and drops unknown ones' do
      stub = stub_programs({ 'first' => '10', 'after' => 'cursor-0' }, page1)

      client.programs.list(first: 10, after: 'cursor-0', bogus: 'x')

      expect(stub).to have_been_requested
    end

    it 'finds a program by name' do
      stub_programs({}, page1)

      program = client.programs.list.data.find { |p| p[:name] == 'Example Program' }

      expect(program[:id]).to eq('program-2')
    end

    it 'stops paging when the API ignores the cursor and returns the same page' do
      stub_request(:get, "#{base_url}/api/programs")
        .with(query: hash_including({}))
        .to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })

      # Bounded so a regression fails instead of looping forever
      pages = client.programs.list.each_page.first(3)

      expect(pages.size).to eq(1)
    end
  end
end
