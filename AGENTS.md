# Agents Guide

## Project Overview

`data_nexus` is a Ruby client gem for Dart Health's Data Nexus API. It wraps the API using Faraday and provides resource-based access.

## Structure

- `lib/data_nexus/` - Main gem code
  - `client.rb` - Entry point for API interactions
  - `configuration.rb` - Config (API keys, base URL, etc.)
  - `connection.rb` - Faraday HTTP connection setup
  - `resources/` - API resource classes
  - `collection.rb` - Collection handling
  - `errors.rb` - Custom error classes
  - `version.rb` - Gem version (bump here for releases)
- `spec/` - RSpec tests
- `.github/workflows/` - CI and release automation

## Development

- Ruby >= 3.0.0
- Run `bundle install` to install dependencies
- Run `bundle exec rspec` to run tests
- Run `bundle exec rubocop` to lint

## Releasing

1. Bump the version in `lib/data_nexus/version.rb`
2. Merge to `main`
3. Create a GitHub Release with tag `vX.Y.Z` matching the version
4. The release workflow runs tests, verifies the version/tag match, builds, and pushes to RubyGems

## When to Suggest a Release

Only suggest a release when there are meaningful changes to the gem's shipped code (anything under `lib/`). Changes that do NOT warrant a release on their own:
- Dependabot dependency bumps (dev dependencies, Gemfile.lock-only changes)
- CI/workflow config changes
- Test-only changes
- Documentation updates

Changes that DO warrant a release:
- Bug fixes in `lib/`
- New features or API changes
- Updates to runtime dependencies in the gemspec (e.g., bumping `faraday` constraint)

## Key Dependencies

- `faraday` (~> 2.0) - HTTP client
- `faraday-retry` (~> 2.0) - Retry middleware
