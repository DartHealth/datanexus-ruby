# Changelog

Notable changes to the `data_nexus` gem. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the gem uses [Semantic Versioning](https://semver.org/).

Dependency bumps, CI changes and test-only changes are left out. From 0.2.0 on, the [GitHub releases](https://github.com/DartHealth/datanexus-ruby/releases) list every merged pull request.

## [Unreleased]

### Added

- `client.programs.list` lists the programs your API key can see, sorted by name. Each program has an `:id` and a `:name`. It pages with `first`, `after`, `before` and `last` (25 programs per page by default), and `name:` filters by program name, ignoring case, so an app can look up a program ID without leaving the gem ([sc-6843](https://app.shortcut.com/dart/story/6843)):

  ```ruby
  program = client.programs.list(name: 'Example Program').data.first
  raise "Program not found: Example Program" unless program

  client.programs(program[:id]).search_members(born_on: '1980-01-15', employee_id: 'EMP123')
  ```

- `Collection#next_page?` and `#previous_page?` return `false` when the response's `has_next_page` or `has_previous_page` is `false`, so iterating a list that sends those flags (such as `client.programs.list`) stops without requesting an empty page.

### Changed

- `client.programs` with no argument now returns the program list instead of raising `ArgumentError`. `client.programs('program-id')` is unchanged.
- `client.programs(nil)` also returns the program list. Code that passes a missing program ID now fails in the gem with `NoMethodError` (for example on `.members`) instead of sending a request to `/api/programs//members`.

### Fixed

- `Collection#next_page` and `#previous_page` return `nil` when the API sends back the same page, so `each`, `each_record` and `each_page` stop instead of looping forever. Program member lists (`client.programs('program-id').members.list`) were affected: the API returns them as a single page that still carries a cursor. Iterating one now stops after that page.

## [0.2.2] - 2026-09-18

### Changed

- Releases are published to RubyGems with trusted publishing. The gem's code is unchanged from 0.2.1.

## [0.2.1] - 2026-02-04

### Fixed

- The default `base_url` is now `https://datanexus.darthealth.com`. It was `https://api.datanexus.com`.

## [0.2.0] - 2026-02-04

### Added

- `client.programs('program-id').search_members(...)` searches a program's members by date of birth plus name, name prefix or employee ID. It returns up to 10 results and a `more_results` flag, and raises `ArgumentError` for an invalid parameter combination.

## [0.1.0] - 2026-01-14

Tagged but not published to RubyGems. 0.2.0 was the first published version and includes everything below.

### Added

- `DataNexus::Client` with API key authentication, timeouts, SSL verification and automatic retries.
- Members: `client.members.list`, `find` and `update`.
- Program members: `client.programs('program-id').members.list`, and `find`, `update` and `household` on a single member.
- Member consents and enrollments: `create`, `find`, `update` and `delete`.
- `DataNexus::Collection` for cursor-paginated lists (`next_page`, `previous_page`, `each_page`, `each`).
- Error classes for API errors (`AuthenticationError`, `NotFoundError`, `RateLimitError` and others) and connection errors.

[Unreleased]: https://github.com/DartHealth/datanexus-ruby/compare/v0.2.2...HEAD
[0.2.2]: https://github.com/DartHealth/datanexus-ruby/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/DartHealth/datanexus-ruby/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/DartHealth/datanexus-ruby/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/DartHealth/datanexus-ruby/tree/v0.1.0
