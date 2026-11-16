# frozen_string_literal: true

RSpec.describe DataNexus::Connection do
  describe 'retries' do
    let(:base_url) { 'https://datanexus.test' }
    let(:member_url) { "#{base_url}/api/members/member-1" }

    before { stub_request(:get, member_url).to_raise(Net::ReadTimeout) }

    def find_member(client)
      client.members.find('member-1')
    rescue DataNexus::TimeoutError
      nil
    end

    it 'defaults to 2 retries' do
      expect(DataNexus::Configuration.new.max_retries).to eq(2)
    end

    it 'retries a timed-out GET twice by default' do
      find_member(DataNexus::Client.new(api_key: 'test-api-key', base_url: base_url))

      expect(a_request(:get, member_url)).to have_been_made.times(3)
    end

    it 'sends a timed-out GET once when max_retries is 0' do
      find_member(DataNexus::Client.new(api_key: 'test-api-key', base_url: base_url, max_retries: 0))

      expect(a_request(:get, member_url)).to have_been_made.once
    end

    it 'retries as many times as max_retries on a Configuration' do
      config = DataNexus::Configuration.new(api_key: 'test-api-key', base_url: base_url, max_retries: 1)

      find_member(DataNexus::Client.new(config: config))

      expect(a_request(:get, member_url)).to have_been_made.twice
    end
  end
end
