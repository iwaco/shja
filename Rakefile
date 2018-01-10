require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

Rake::TestTask.new(:unit) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/unit/**/*_test.rb']
end

Rake::TestTask.new(:functional) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/functional/**/*_test.rb']
end

task :default => :test
