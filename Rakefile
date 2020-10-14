task :default => [:package]

task :package do
  system("gem build grok.gemspec")
end

task :publish do
  latest_gem = %x{ls -t jls-grok*.gem}.split("\n").first
  system("gem push #{latest_gem}")
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end
