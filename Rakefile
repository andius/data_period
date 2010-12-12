require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Test the data_period plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'lib/data_period'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
