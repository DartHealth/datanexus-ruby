# frozen_string_literal: true

RSpec.describe DataNexus::UnprocessableEntityError do
  let(:base_url) { 'https://datanexus.test' }
  let(:client) { DataNexus::Client.new(api_key: 'test-api-key', base_url: base_url) }
  let(:not_eligible_detail) { 'Member is not eligible for this program on the enrollment date.' }
  let(:validation_error) do
    {
      title: 'Invalid value',
      source: { pointer: '/enrollment/enrolled_at' },
      detail: 'Invalid format. Expected :"date-time"'
    }
  end

  def stub_enrollment_create(body)
    stub_request(:post, "#{base_url}/api/members/member-1/enrollments")
      .to_return(status: 422, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def create_enrollment
    client.programs('program-1').members('member-1').enrollments.create(
      enrollment: { enrolled_at: '2026-01-01T00:00:00Z' }
    )
  end

  def raise_unprocessable(**attributes)
    raise_error(an_instance_of(described_class).and(having_attributes(**attributes)))
  end

  it 'exposes the code and detail of a coded 422' do
    stub_enrollment_create(errors: { code: 'not_eligible_for_program', detail: not_eligible_detail })

    expect { create_enrollment }.to raise_unprocessable(code: 'not_eligible_for_program', message: not_eligible_detail)
  end

  it 'has no code and a readable message for field errors' do
    stub_enrollment_create(errors: { expires_at: ['must be after enrolled_at'] })

    expect { create_enrollment }.to raise_unprocessable(code: nil, message: 'expires_at must be after enrolled_at')
  end

  it 'has no code and a readable message for request validation errors' do
    stub_enrollment_create(errors: [validation_error])

    expect { create_enrollment }.to raise_unprocessable(
      code: nil, message: '/enrollment/enrolled_at: Invalid format. Expected :"date-time"'
    )
  end

  it 'uses the detail of an uncoded 422' do
    stub_enrollment_create(errors: { detail: 'Unprocessable Content' })

    expect { create_enrollment }.to raise_unprocessable(code: nil, message: 'Unprocessable Content')
  end
end
