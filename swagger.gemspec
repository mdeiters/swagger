Gem::Specification.new do |s|
  s.name = %q{swagger}
  s.version = "1.4.0"

  s.required_rubygems_version = ">= 1.3.6"
  s.authors = ["mdeiters", "Justin Ko"]
  s.date = %q{2011-01-14}
  s.description = %q{Duck punch Resque to use active record for backround jobs instead of redis}
  s.email = %q{mdeiters@gmail.com}
  s.files = `git ls-files`.split("\n")
  s.homepage = %q{http://github.com/mdeiters/swagger}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_path = "lib"
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Everything Resque provides minus Redis}


  s.add_runtime_dependency("activerecord", ">= 0")
  s.add_runtime_dependency("resque", ">= 1.10.0")

  s.add_development_dependency("rake", "~> 0.8.7")
  s.add_development_dependency("rspec", ">= 2.4.0")
  s.add_development_dependency("sqlite3", ">= 1.3.3")
end