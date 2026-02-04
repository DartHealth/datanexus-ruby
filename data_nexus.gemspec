# frozen_string_literal: true

require_relative 'lib/data_nexus/version'

Gem::Specification.new do |spec|
  spec.name = 'data_nexus'
  spec.version = DataNexus::VERSION
  spec.authors = ['Alex Kibler']
  spec.email = ['alexkibler@me.com']

  spec.summary = 'Ruby client for the DataNexus API'
  spec.description = "A Ruby gem for interacting with Dart Health's Data Nexus API."
  spec.homepage = 'https://github.com/DartHealth/datanexus-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'faraday-retry', '~> 2.0'
end
