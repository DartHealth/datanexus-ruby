# SC-7043 Gem README Require Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the datanexus-ruby README show how to load the gem, so its Usage example runs when copied into a plain Ruby script.

**Architecture:** A one-line documentation change to `README.md` in `DartHealth/datanexus-ruby`: add `require 'data_nexus'` to the top of the Usage example. Every later README example builds on the `client` that block creates, so this one line covers them all. Verification is a throwaway harness outside the repo that extracts README blocks and runs them against the repo's own `lib/` with HTTP stubbed. Nothing in the harness is committed.

**Tech Stack:** Markdown, Ruby 3.4 (local), the gem's own `lib/` at `origin/main` (`64edfef`, which is v0.3.0), `gh` CLI.

**Spec:** Shortcut [SC-7043](https://app.shortcut.com/dart/story/7043)

## Global Constraints

- Repo: `~/src/darthealth/datanexus-ruby` (remote `DartHealth/datanexus-ruby`). Branch from `origin/main`.
- Branch name: `briansage/sc-7043/readme-require` (the repo's existing `briansage/sc-NNNN/<slug>` pattern).
- Brian's global git config sets `push.default tracking`. Branch with `--no-track` and push with the full `HEAD:refs/heads/<branch>` refspec. A branch that tracks `origin/main` pushes to `main`.
- Change only the Usage code block in `README.md`, plus `docs/` in the gemspec's `spec.files` reject list so committed plans don't ship in the gem. Don't edit `CHANGELOG.md`. The README isn't gem behaviour, and the 0.3.0 entry is already released.
- No version bump. This doesn't need a gem release.
- Never call the real Data Nexus API. Every run uses the stub harness and the fake key `test-key`.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. PR descriptions end with `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
- Serial (Oxford) commas in all prose: the PR description and the card comment.
- `~/.gitignore` ignores dotfiles. This change touches no dot-paths, so `git add README.md` is enough.

## Review Focus

- **The README's own lookup flow (Usage, then "Look Up a Program by Name"), run as one script:** it should run on a match and stop with "Program not found" on no match. Task 1, Step 4 runs both cases.
- **An app that already loaded the gem through `Bundler.require`:** the added `require` must be a no-op. Task 1, Step 5 checks it.
- **`base_url:` left as written:** the Usage block passes the production URL as "optional". Under the stub no request is sent, so the URL doesn't matter. Leave it unchanged.
- **CI:** README-only changes still trigger `ci.yml` (rspec and rubocop) on the PR. It should pass unchanged. Task 2, Step 2 waits for it.

---

### Task 1: Add the require to the README Usage example

**Files:**
- Modify: `README.md`, the ```ruby block under `## Usage`
- Test (outside the repo, not committed): `$H/stub_http.rb` and `$H/extract_block.rb`, where `H="${TMPDIR:-/tmp}/readme-check-sc-7043"`

**Interfaces:**
- Consumes: the repo's own `lib/` (`DataNexus::Client`, `DataNexus::Connection#get` and `#post`)
- Produces: the commit on branch `briansage/sc-7043/readme-require` that Task 2 pushes

- [ ] **Step 1: Branch and build the harness**

```bash
cd ~/src/darthealth/datanexus-ruby
git status --porcelain   # expected: no output
git fetch origin
git switch --no-track -c briansage/sc-7043/readme-require origin/main

H="${TMPDIR:-/tmp}/readme-check-sc-7043"
mkdir -p "$H"
```

Write `$H/stub_http.rb`:

```ruby
# Loaded with `ruby -r`. Defines nothing in DataNexus, so a script that never
# requires the gem still hits NameError. Once the script requires 'data_nexus',
# DataNexus::Connection#get/#post are replaced so no request leaves the machine.
# STUB_PROGRAMS=match (default) returns one program; STUB_PROGRAMS=none returns [].
module DataNexusHttpStub
  def get(_path, _params = {})
    programs = ENV.fetch('STUB_PROGRAMS', 'match') == 'match' ? [{ id: 'p-1', name: 'Example Program' }] : []
    { data: programs, has_next_page: false, has_previous_page: false }
  end

  def post(_path, _body = {})
    { data: [{ first_name: 'Jane', last_name: 'Doe' }], more_results: false }
  end
end

module StubOnRequire
  def require(name)
    super.tap do
      if name == 'data_nexus' && !(DataNexus::Connection < DataNexusHttpStub)
        DataNexus::Connection.prepend(DataNexusHttpStub)
      end
    end
  end
end
Kernel.prepend(StubOnRequire)
```

Write `$H/extract_block.rb`:

```ruby
# Usage: ruby extract_block.rb README.md "## Heading" N
# Prints the Nth (1-based) ```ruby block that follows the heading line.
path, heading, n = ARGV
lines = File.readlines(path)
start = lines.index { |l| l.chomp == heading } or abort("heading not found: #{heading}")
blocks = []
cur = nil
lines[(start + 1)..].each do |l|
  if cur.nil? && l.start_with?('```ruby') then cur = +''
  elsif cur && l.start_with?('```') then blocks << cur; cur = nil
  elsif cur then cur << l
  end
end
block = blocks[Integer(n) - 1] or abort("block #{n} not found")
print block
```

- [ ] **Step 2: Run the Usage example to verify it fails**

```bash
H="${TMPDIR:-/tmp}/readme-check-sc-7043"; cd ~/src/darthealth/datanexus-ruby
ruby "$H/extract_block.rb" README.md '## Usage' 1 > "$H/usage.rb"
DATANEXUS_API_KEY=test-key ruby -I lib -r "$H/stub_http.rb" "$H/usage.rb" 2>&1 | head -1
```

Expected: `usage.rb:1:in '<main>': uninitialized constant DataNexus (NameError)`

- [ ] **Step 3: Write the minimal fix**

In `README.md`, change the block under `## Usage` from:

```ruby
client = DataNexus::Client.new(
  api_key: ENV['DATANEXUS_API_KEY'],
  base_url: 'https://datanexus.darthealth.com'  # optional
)
```

to:

```ruby
require 'data_nexus'

client = DataNexus::Client.new(
  api_key: ENV['DATANEXUS_API_KEY'],
  base_url: 'https://datanexus.darthealth.com'  # optional
)
```

- [ ] **Step 4: Run the Usage example, then the full lookup flow, to verify they pass**

```bash
H="${TMPDIR:-/tmp}/readme-check-sc-7043"; cd ~/src/darthealth/datanexus-ruby
ruby "$H/extract_block.rb" README.md '## Usage' 1 > "$H/usage.rb"
DATANEXUS_API_KEY=test-key ruby -I lib -r "$H/stub_http.rb" "$H/usage.rb"; echo "exit=$?"

{ cat "$H/usage.rb"; ruby "$H/extract_block.rb" README.md '### Look Up a Program by Name' 1; } > "$H/flow.rb"
DATANEXUS_API_KEY=test-key ruby -I lib -r "$H/stub_http.rb" "$H/flow.rb"; echo "exit=$?"
DATANEXUS_API_KEY=test-key STUB_PROGRAMS=none ruby -I lib -r "$H/stub_http.rb" "$H/flow.rb" 2>&1 | head -1
```

Expected:
- Usage alone: no output, then `exit=0`
- The flow with a match: no output, then `exit=0` (the README example doesn't print its search result)
- The flow with no match: `flow.rb:8:in '<main>': Program not found: Example Program (RuntimeError)`

- [ ] **Step 5: Check the Review Focus case for an app that already loaded the gem**

```bash
H="${TMPDIR:-/tmp}/readme-check-sc-7043"; cd ~/src/darthealth/datanexus-ruby
DATANEXUS_API_KEY=test-key ruby -I lib -r "$H/stub_http.rb" -e "require 'data_nexus'; load '$H/usage.rb'"; echo "exit=$?"
```

Expected: no output, then `exit=0`

- [ ] **Step 6: Confirm the diff is one line plus one blank line**

```bash
cd ~/src/darthealth/datanexus-ruby && git diff --stat && git diff
```

Expected: `README.md | 2 ++`, with `require 'data_nexus'` and a blank line added at the top of the Usage block. Nothing removed.

- [ ] **Step 7: Commit**

```bash
cd ~/src/darthealth/datanexus-ruby
git add README.md
git commit -m "$(cat <<'EOF'
Show require 'data_nexus' in the README's Usage example (SC-7043)

Copied into a plain Ruby script, the Usage example raised
NameError: uninitialized constant DataNexus, because nothing loaded the gem.
Apps that call Bundler.require were unaffected.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
EOF
)"
```

### Task 2: Open the PR, post the card status, and clean up

**Files:** none in the repo.

**Interfaces:**
- Consumes: the commit from Task 1
- Produces: the PR URL, which is posted on SC-7043

- [ ] **Step 1: Push and open the PR**

```bash
cd ~/src/darthealth/datanexus-ruby
git push -u origin HEAD:refs/heads/briansage/sc-7043/readme-require
gh pr create --base main --title "Show require 'data_nexus' in the README's Usage example (sc-7043)" --body "$(cat <<'EOF'
## Summary

The README never showed `require 'data_nexus'`, so copying the Usage example into a plain Ruby script raised `NameError: uninitialized constant DataNexus`. This adds the `require` to the top of the Usage block. Every later example builds on the `client` created there.

This is a README-only change: no version bump and no CHANGELOG entry.

## Verification

Extracted the README blocks and ran them against this branch's `lib/`, with HTTP stubbed and no real API calls:

- The Usage block runs cleanly.
- Usage followed by "Look Up a Program by Name" runs on a match and raises `Program not found: Example Program` on no match.
- With the gem already loaded (as in Rails), the extra `require` does nothing.

Shortcut: [sc-7043](https://app.shortcut.com/dart/story/7043)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Expected: `gh` prints the PR URL.

- [ ] **Step 2: Wait for CI**

```bash
cd ~/src/darthealth/datanexus-ruby && gh pr checks --watch
```

Expected: every check passes. If any check fails, stop and report the failing check's log. A README change shouldn't break rspec or rubocop, so a failure means something else changed on `main`.

- [ ] **Step 3: Post the PR-opened status comment on SC-7043**

Engage `dart-shortcut:shortcut-cards` first. Using the `shortcut-dart` MCP server, add a comment on story 7043 with exactly this text, filling in the URL from Step 1:

```
PR opened: <PR URL from Step 1>

_Posted by Claude for Brian Sage_
```

Don't change the card's state. Moving it is Brian's call.

- [ ] **Step 4: Remove the harness**

```bash
rm -rf "${TMPDIR:-/tmp}/readme-check-sc-7043"
```
