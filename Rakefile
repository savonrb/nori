require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"

desc "Benchmark Nori parsers"
task :benchmark do
  require "benchmark/benchmark"
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-c)
end

task :default => :spec
task :test => :spec
