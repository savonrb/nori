source 'https://rubygems.org'
gemspec

if RUBY_VERSION >= "3"
  gem "rexml", "~> 3.2"
end

gem "bundler-audit", "~> 0.9.3", require: false
gem "rubocop", "~> 1.86", ">= 1.86.2"
gem "rubocop-rake", "~> 0.7.1"
gem "rubocop-rspec", "~> 3.9"
# ruby_audit 3.x requires Ruby >= 3.1. Only the CI audit job needs it.
gem "ruby_audit", "~> 3.1", require: false if RUBY_VERSION >= "3.1.0"
gem "simplecov", require: false
