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
- `CHANGELOG.md` - User-facing changes per release
- `spec/` - RSpec tests
- `.github/workflows/` - CI and release automation

## Development

- Ruby >= 3.0.0
- Run `bundle install` to install dependencies
- Run `bundle exec rspec` to run tests
- Run `bundle exec rubocop` to lint

## GitHub Actions scanning

`.github/workflows/github-actions-scan.yml` runs zizmor (security) and actionlint (correctness) on every PR and on every push to `main`, and fails on any finding. Before pushing a workflow change, run both locally:

- `GH_TOKEN=$(gh auth token) zizmor .` (without a token, zizmor skips its online audits)
- `actionlint`

Pin every action to a full commit SHA, with the exact version in a comment; `pinact run` does this. Dependabot keeps the pins current. To suppress a finding, add `# zizmor: ignore[<audit>]` with a reason on the offending line.

## Releasing

1. Bump the version in `lib/data_nexus/version.rb`. In `CHANGELOG.md`, rename `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD`, add a new empty `## [Unreleased]` section above it, and update the links at the bottom: `[Unreleased]` compares `vX.Y.Z...HEAD`, and a new `[X.Y.Z]` link compares the previous tag to `vX.Y.Z`
2. Merge to `main`
3. Create a GitHub Release with tag `vX.Y.Z` matching the version. Paste that version's `CHANGELOG.md` section above GitHub's generated pull request list
4. The release workflow runs tests, verifies the version/tag match, builds, and pushes to RubyGems

Any pull request that changes shipped behavior (anything under `lib/`, or runtime dependencies in the gemspec) adds an entry under `[Unreleased]` in `CHANGELOG.md`.

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
