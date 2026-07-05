unless RUBY_PLATFORM =~ /java/
  require "simplecov"
  SimpleCov.start do
    add_filter "spec"
  end
end

require "bundler"
Bundler.require :default, :development
