# DataNexus

Ruby client for the DataNexus API.

## Installation

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
member = client.programs('program-id').members.find('member-id')
puts member[:first_name]
```

### Update Member

```ruby
response = client.programs('program-id').members.update('member-id',
  member: { phone_number: '+15551234567' }
)
```

### Household Members

```ruby
household = client.programs('program-id').members.household('member-id')
household.data.each { |member| puts member[:first_name] }
```

### Member Consents

#### Create Consent

```ruby
response = client.programs('program-id').members.consents('member-id').create(
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
consent = client.programs('program-id').members.consents('member-id').find(123)
puts consent[:category]
```

#### Update Consent

```ruby
response = client.programs('program-id').members.consents('member-id').update(123,
  consent: { member_response: false }
)
```

#### Delete Consent

```ruby
client.programs('program-id').members.consents('member-id').delete(123)
```

## Error Handling

```ruby
begin
  client.programs('id').members.find('id')
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

```
cp .mise.local.toml.example .mise.local.toml
# Edit .mise.local.toml with your test credentials
mise run test
mise run lint
```

## License

MIT