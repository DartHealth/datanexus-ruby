# frozen_string_literal: true

RSpec::Matchers.define_negated_matcher :excluding, :include

RSpec.describe DataNexus::Resources::Programs do
  let(:base_url) { 'https://datanexus.test' }
  let(:client) { DataNexus::Client.new(api_key: 'test-api-key', base_url: base_url) }
  let(:verify_url) { "#{base_url}/api/programs/program-1/members/verify" }

  let(:fields) do
    { first_name: 'Georgina', last_name: 'Washburne', born_on: '1976-07-04', employee_id: 'EMP123' }
  end

  let(:submitted) { %w[Georgina Washburne 1976-07-04 EMP123] }

  def stub_verify(status:, body:)
    stub_request(:post, verify_url)
      .to_return(status: status, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def verify(**overrides)
    client.programs('program-1').verify_member(**fields, **overrides)
  end

  def captured_error
    yield
    raise 'expected an error'
  rescue StandardError => e
    e
  end

  describe '#verify_member' do
    it 'posts the four fields to the verify endpoint' do
      stub_verify(status: 200, body: { data: { status: 'verified', member_id: 'member-1' } })

      verify

      expect(a_request(:post, verify_url).with(body: fields.to_json)).to have_been_made.once
    end

    %w[verified ineligible].each do |status|
      it "returns the #{status} status with the member ID" do
        stub_verify(status: 200, body: { data: { status: status, member_id: 'member-1' } })

        expect(verify).to eq(status: status, member_id: 'member-1')
      end
    end

    %w[not_found multiple_matches].each do |status|
      it "returns the #{status} status with no member ID" do
        stub_verify(status: 200, body: { data: { status: status, member_id: nil } })

        expect(verify).to eq(status: status, member_id: nil)
      end
    end

    %i[first_name last_name born_on employee_id].each do |field|
      [nil, '', '  '].each do |blank|
        it "raises ArgumentError naming #{field} when it is #{blank.inspect}" do
          expect { verify(field => blank) }.to raise_error(ArgumentError, /#{field}/)
        end
      end

      it "raises ArgumentError naming #{field} when it is left out" do
        expect { client.programs('program-1').verify_member(**fields.except(field)) }
          .to raise_error(ArgumentError, /#{field}/)
      end
    end

    it 'sends no request when a field is blank' do
      captured_error { verify(employee_id: '') }

      expect(a_request(:post, verify_url)).not_to have_been_made
    end

    it 'leaves submitted values out of the ArgumentError message' do
      expect { verify(first_name: '', last_name: ' ') }
        .to raise_error(ArgumentError, excluding('Washburne', '1976-07-04', 'EMP123'))
    end

    it 'raises NotFoundError on a 404 instead of returning not_found' do
      stub_verify(status: 404, body: { errors: { detail: 'Not Found' } })

      expect { verify }.to raise_error(DataNexus::NotFoundError)
    end

    it 'raises UnprocessableEntityError on a 422 without the submitted values in its message' do
      stub_verify(status: 422, body: { errors: [{ title: 'Invalid value', source: { pointer: '/born_on' },
                                                  detail: 'Invalid format. Expected :date' }] })

      expect { verify }.to raise_error(DataNexus::UnprocessableEntityError, excluding(*submitted))
    end

    it 'raises TimeoutError on a timeout without the submitted values in its message' do
      stub_request(:post, verify_url).to_raise(Net::ReadTimeout)

      expect { verify }.to raise_error(DataNexus::TimeoutError, excluding(*submitted))
    end

    it 'does not retry a timed-out verify' do
      stub_request(:post, verify_url).to_raise(Net::ReadTimeout)

      captured_error { verify }

      expect(a_request(:post, verify_url)).to have_been_made.once
    end
  end
end
