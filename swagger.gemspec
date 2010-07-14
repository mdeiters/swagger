# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{swagger}
  s.version = "1.1.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["mdeiters"]
  s.date = %q{2010-07-14}
  s.description = %q{Duck punch Resque to use active record for backround jobs instead of redis}
  s.email = %q{mdeiters@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/redis_impersonator.rb",
     "lib/resque_extension.rb",
     "lib/resque_value.rb",
     "lib/swagger.rb",
     "spec/redis_impersonator_spec.rb",
     "spec/resque_extension_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "swagger.gemspec"
  ]
  s.homepage = %q{http://github.com/mdeiters/swagger}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Everything Resque provides minus Redis}
  s.test_files = [
    "spec/redis_impersonator_spec.rb",
     "spec/resque_extension_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_runtime_dependency(%q<resque>, ["= 1.9.7"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<resque>, ["= 1.9.7"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<resque>, ["= 1.9.7"])
  end
end

