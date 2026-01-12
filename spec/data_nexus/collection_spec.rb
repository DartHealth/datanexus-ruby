# frozen_string_literal: true

RSpec.describe DataNexus::Collection do
  let(:response) do
    {
      data: [
        { id: '1', first_name: 'George', last_name: 'Washington' },
        { id: '2', first_name: 'John', last_name: 'Adams' }
      ],
      start_cursor: 'start_abc',
      end_cursor: 'end_xyz'
    }
  end

  let(:resource) { instance_spy(DataNexus::Resources::ProgramMembers) }
  let(:params) { { first: 50, born_on: '1976-07-04' } }
  let(:collection) { described_class.new(response, resource: resource, params: params) }

  describe '#data' do
    it 'returns the data array from the response' do
      expect(collection.data).to eq(response[:data])
    end

    it 'returns an empty array when response has no data' do
      empty_collection = described_class.new({}, resource: resource, params: params)
      expect(empty_collection.data).to eq([])
    end
  end

  describe '#start_cursor' do
    it 'returns the start cursor from the response' do
      expect(collection.start_cursor).to eq('start_abc')
    end
  end

  describe '#end_cursor' do
    it 'returns the end cursor from the response' do
      expect(collection.end_cursor).to eq('end_xyz')
    end
  end

  describe '#size' do
    it 'returns the number of records in the page' do
      expect(collection.size).to eq(2)
    end
  end

  describe '#length' do
    it 'is an alias for size' do
      expect(collection.length).to eq(collection.size)
    end
  end

  describe '#empty?' do
    it 'returns false when there are records' do
      expect(collection.empty?).to be false
    end

    it 'returns true when there are no records' do
      empty_collection = described_class.new({ data: [] }, resource: resource, params: params)
      expect(empty_collection.empty?).to be true
    end
  end

  describe '#next_page?' do
    it 'returns true when end_cursor is present' do
      expect(collection.next_page?).to be true
    end

    it 'returns false when end_cursor is nil' do
      no_next = described_class.new({ data: [], end_cursor: nil }, resource: resource, params: params)
      expect(no_next.next_page?).to be false
    end

    it 'returns false when end_cursor is empty' do
      no_next = described_class.new({ data: [], end_cursor: '' }, resource: resource, params: params)
      expect(no_next.next_page?).to be false
    end
  end

  describe '#previous_page?' do
    it 'returns true when start_cursor is present' do
      expect(collection.previous_page?).to be true
    end

    it 'returns false when start_cursor is nil' do
      no_prev = described_class.new({ data: [], start_cursor: nil }, resource: resource, params: params)
      expect(no_prev.previous_page?).to be false
    end

    it 'returns false when start_cursor is empty' do
      no_prev = described_class.new({ data: [], start_cursor: '' }, resource: resource, params: params)
      expect(no_prev.previous_page?).to be false
    end
  end

  describe '#next_page' do
    it 'returns nil when there is no next page' do
      no_next = described_class.new({ data: [], end_cursor: nil }, resource: resource, params: params)
      expect(no_next.next_page).to be_nil
    end

    it 'calls list on the resource with the end_cursor' do
      collection.next_page
      expect(resource).to have_received(:list).with(first: 50, born_on: '1976-07-04', after: 'end_xyz')
    end
  end

  describe '#previous_page' do
    it 'returns nil when there is no previous page' do
      no_prev = described_class.new({ data: [], start_cursor: nil }, resource: resource, params: params)
      expect(no_prev.previous_page).to be_nil
    end

    it 'calls list on the resource with the start_cursor' do
      collection.previous_page
      expect(resource).to have_received(:list).with(first: 50, born_on: '1976-07-04', before: 'start_abc')
    end
  end

  describe '#each_page' do
    it 'returns an enumerator when no block given' do
      expect(collection.each_page).to be_a(Enumerator)
    end

    it 'yields the current page first' do
      first_page = collection.each_page.first
      expect(first_page).to eq(collection)
    end

    it 'yields subsequent pages from the resource' do
      page2 = described_class.new({ data: [{ id: '3' }], end_cursor: nil }, resource: resource, params: params)
      allow(resource).to receive(:list).and_return(page2)

      pages = collection.each_page.to_a

      expect(pages.size).to eq(2)
    end

    it 'stops when there is no next page' do
      last_page = described_class.new({ data: [{ id: '1' }], end_cursor: nil }, resource: resource, params: params)
      pages = last_page.each_page.to_a
      expect(pages.size).to eq(1)
    end
  end

  describe '#each_record' do
    it 'returns an enumerator when no block given' do
      expect(collection.each_record).to be_a(Enumerator)
    end

    it 'yields each record from the current page' do
      last_page = described_class.new(response.merge(end_cursor: nil), resource: resource, params: params)
      records = last_page.each_record.to_a
      expect(records.map { |r| r[:id] }).to eq(%w[1 2])
    end

    it 'yields records across multiple pages' do
      page2 = described_class.new({ data: [{ id: '3' }], end_cursor: nil }, resource: resource, params: params)
      allow(resource).to receive(:list).and_return(page2)

      records = collection.each_record.to_a

      expect(records.size).to eq(3)
    end
  end

  describe '#each' do
    it 'is an alias for each_record' do
      expect(collection.method(:each)).to eq(collection.method(:each_record))
    end
  end
end
