require 'rake/testtask'
require 'lib/url_note.rb'

task :default => [:test]

task :create_db do
  UrlNote.create_db
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
