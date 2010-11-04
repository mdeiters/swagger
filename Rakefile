require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "swagger"
    gem.summary = %Q{Everything Resque provides minus Redis}
    gem.description = %Q{Duck punch Resque to use active record for backround jobs instead of redis}
    gem.email = "mdeiters@gmail.com"
    gem.homepage = "http://github.com/mdeiters/swagger"
    gem.authors = ["mdeiters"]
    gem.add_development_dependency "rspec", "> 2"
    gem.add_development_dependency "sqlite3-ruby"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.add_dependency "activerecord" #, "2.3.8"
    gem.add_dependency "resque"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = "--color"
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rspec_opts = "--color"
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  require File.expand_path( File.dirname(__FILE__) + "/lib/swagger/version" )

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "swagger #{Swagger.version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
