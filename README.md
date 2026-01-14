# DataNexus

Ruby client for the DataNexus API.

## Installation

Install from GitHub (before gem is published):

```ruby
gem 'data_nexus', git: 'https://github.com/DartHealth/datanexus-ruby.git', tag: 'v0.1.0'
```

Or from RubyGems (once published):

```ruby
gem 'data_nexus'
```

## Usage

```ruby
client = DataNexus::Client.new(
  api_key: ENV['DATANEXUS_API_KEY'],
  base_url: 'https://api.datanexus.com'  # optional
)
```

## Program Members

### List Members

Filters are required. Valid combinations:
- `born_on` + `employee_id`
- `born_on` + `first_name` + `last_name`
- `born_on` + `first_name_prefix` + `last_name_prefix`

```ruby
collection = client.programs('program-id').members.list(
  born_on: '1980-01-15',
  employee_id: 'EMP123'
)

collection.data.each do |member|
  puts "#{member[:first_name]} #{member[:last_name]}"
end
```

### Pagination

```ruby
collection.each_page do |page|
  page.data.each { |member| process(member) }
end

# Or iterate all records directly
collection.each { |member| process(member) }

# Manual pagination
if collection.next_page?
  next_collection = collection.next_page
end
```

### Find Member

```ruby
member = client.programs('program-id').members('member-id').find
puts member[:first_name]
```

### Update Member

```ruby
response = client.programs('program-id').members('member-id').update(
  member: { phone_number: '+15551234567' }
)
```

### Household Members

```ruby
household = client.programs('program-id').members('member-id').household
household.each { |member| puts member[:first_name] }
```

### Member Consents

#### Create Consent

```ruby
response = client.programs('program-id').members('member-id').consents.create(
  consent: {
    category: 'sms',
    member_response: true,
    consent_details: { sms_phone_number: '+15558675309' }
  }
)
# program_id is automatically injected
```

#### Find Consent

```ruby
consent = client.programs('program-id').members('member-id').consents.find(123)
puts consent[:category]
```

#### Update Consent

```ruby
response = client.programs('program-id').members('member-id').consents.update(123,
  consent: { member_response: false }
)
```

#### Delete Consent

```ruby
client.programs('program-id').members('member-id').consents.delete(123)
```

### Member Enrollments

#### Create Enrollment

```ruby
response = client.programs('program-id').members('member-id').enrollments.create(
  enrollment: {
    enrolled_at: '2024-01-01T00:00:00Z',
    expires_at: '2025-01-01T00:00:00Z'
  }
)
# program_id is automatically injected
```

#### Find Enrollment

```ruby
enrollment = client.programs('program-id').members('member-id').enrollments.find(123)
puts enrollment[:enrolled_at]
```

#### Update Enrollment

```ruby
response = client.programs('program-id').members('member-id').enrollments.update(123,
  enrollment: { expires_at: '2026-01-01T00:00:00Z' }
)
```

#### Delete Enrollment

```ruby
client.programs('program-id').members('member-id').enrollments.delete(123)
```

## Top-Level Members

You can also access members without a program scope:

### List Members

```ruby
collection = client.members.list(
  first_name: 'George',
  last_name: 'Washington',
  born_on: '1976-07-04'
)

# Filter by program eligibility
collection = client.members.list(program_id: 'program-uuid')

# Filter by update time
collection = client.members.list(updated_since: '2024-01-01T00:00:00Z')

# Pagination
collection = client.members.list(first: 50, after: 'cursor')
```

### Find Member

```ruby
member = client.members.find('member-id')
puts member[:first_name]
```

### Update Member

```ruby
response = client.members.update('member-id',
  member: { phone_number: '+15551234567' }
)
```

## Error Handling

```ruby
begin
  client.programs('id').members('id').find
rescue DataNexus::AuthenticationError
  # 401
rescue DataNexus::NotFoundError
  # 404
rescue DataNexus::UnprocessableEntityError
  # 422
rescue DataNexus::RateLimitError => e
  sleep(e.retry_after)
rescue DataNexus::APIError => e
  puts "#{e.status}: #{e.message}"
end
```

## Development

```bash
cp .mise.local.toml.example .mise.local.toml
# Edit .mise.local.toml with your test credentials
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT