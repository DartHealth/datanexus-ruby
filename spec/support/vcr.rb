# frozen_string_literal: true

require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter sensitive data
  config.filter_sensitive_data('<API_KEY>') { ENV.fetch('DATANEXUS_API_KEY', 'test-api-key') }
  config.filter_sensitive_data('<PROGRAM_ID>') { ENV.fetch('DATANEXUS_TEST_PROGRAM_ID', 'test-program-id') }
  config.filter_sensitive_data('<MEMBER_ID>') { ENV.fetch('DATANEXUS_TEST_MEMBER_ID', 'test-member-id') }
  config.filter_sensitive_data('<BORN_ON>') { ENV.fetch('DATANEXUS_TEST_BORN_ON', '1970-01-01') }
  config.filter_sensitive_data('<EMPLOYEE_ID>') { ENV.fetch('DATANEXUS_TEST_EMPLOYEE_ID', 'test-employee-id') }

  # Match requests on method and path only (ignore query params for flexibility)
  config.default_cassette_options = {
    record: :once,
    match_requests_on: %i[method path]
  }
end
