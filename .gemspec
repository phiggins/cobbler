# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cobbler}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["pete higgins"]
  s.date = %q{2009-11-12}
  s.description = %q{Cobbler is a reworked version of the Shoes packager app that is scriptable
instead of GUI based.}
  s.email = ["pete@peterhiggins.org"]
  s.extra_rdoc_files = ["Manifest.txt", "README.txt", "History.txt"]
  s.files = ["lib/cobbler/pack.rb", "lib/cobbler.rb", "test/test_cobbler.rb", "Rakefile", "Manifest.txt", "README.txt", "History.txt"]
  s.homepage = %q{http://github.com/phiggy/cobbler }
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cobbler}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Cobbler is a reworked version of the Shoes packager app that is scriptable instead of GUI based.}
  s.test_files = ["test/test_cobbler.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
