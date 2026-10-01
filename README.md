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
  base_url: 'https://datanexus.darthealth.com'  # optional
)
```

## Programs

### List Programs

Lists the programs your API key can see, sorted by name. Each program has an `:id` and a `:name`.

```ruby
collection = client.programs.list

collection.data.each do |program|
  puts "#{program[:id]} #{program[:name]}"
end
```

A page holds 25 programs by default. `list` takes `first`, `after`, `before` and `last`, and `each` reads every page. See [Pagination](#pagination).

### Look Up a Program by Name

Every program-scoped call needs a program ID. To start from a program's name, filter by `name`. The match ignores case and surrounding whitespace:

```ruby
program = client.programs.list(name: 'Example Program').data.first
raise "Program not found: Example Program" unless program

client.programs(program[:id]).search_members(
  born_on: '1980-01-15',
  employee_id: 'EMP123'
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

Note: Program member lists return a single page of up to 25 members. See [Pagination](#pagination).

### Search Members

Search for members within a program. Returns a bounded result set (max 10 results) with a `more_results` flag indicating if additional matches exist.

Valid parameter combinations:
- `born_on` + `employee_id`
- `born_on` + `first_name` + `last_name`
- `born_on` + `first_name` + `last_name` + `employee_id`
- `born_on` + `first_name_prefix` + `last_name_prefix`
- `born_on` + `first_name_prefix` + `last_name_prefix` + `employee_id`

```ruby
# Search by employee ID and DOB
result = client.programs('program-id').search_members(
  born_on: '1980-01-15',
  employee_id: 'EMP123'
)

result[:data].each do |member|
  puts "#{member[:first_name]} #{member[:last_name]}"
end

puts "More results available" if result[:more_results]

# Search by name and DOB
result = client.programs('program-id').search_members(
  born_on: '1980-01-15',
  first_name: 'George',
  last_name: 'Washington'
)

# Search by name prefix and DOB
result = client.programs('program-id').search_members(
  born_on: '1980-01-15',
  first_name_prefix: 'G',
  last_name_prefix: 'Was'
)
```

Note: `search_members` does not support pagination. It returns up to 10 results with a `more_results` boolean. An `ArgumentError` will be raised if an invalid parameter combination is provided.

Note: Depending on your API key, `search_members` may be the only method you have access to. Contact your DataNexus representative for more information about your API key's permissions.

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

## Pagination

`list` methods return a `DataNexus::Collection`, one page of records plus cursors. Program lists (`client.programs.list`) and top-level member lists (`client.members.list`) page with `first`, `after`, `before` and `last`:

```ruby
collection = client.members.list(first: 50)

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

Note: Program member lists (`client.programs('program-id').members.list`) currently return a single page of up to 25 records. `each` and `each_page` stop after that page. `next_page?` can still return `true` for these lists, and `next_page` then returns `nil`.

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