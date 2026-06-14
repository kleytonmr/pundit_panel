# frozen_string_literal: true

require_relative "lib/pundit_panel/version"

Gem::Specification.new do |spec|
  spec.name = "pundit_panel"
  spec.version = PunditPanel::VERSION
  spec.authors = ["Kleytonmr"]
  spec.email = ["kleytonmatosramos@gmail.com"]

  spec.summary = "Web UI for managing Pundit authorization roles and permissions"
  spec.description = "A mountable Rails engine that provides a plug-and-play admin interface to manage Pundit roles and permissions. Supports enum-based roles and database-backed role models."
  spec.homepage = "https://github.com/bioritmo/pundit_panel"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "pundit", ">= 2.0"
end
