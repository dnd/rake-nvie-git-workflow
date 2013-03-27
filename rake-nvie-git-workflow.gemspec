# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake-nvie-git-workflow/version'

Gem::Specification.new do |gem|
  gem.name          = "rake-nvie-git-workflow"
  gem.version       = Rake::Nvie::Git::Workflow::VERSION
  gem.authors       = ["Steve Valaitis"]
  gem.email         = ["steve@digitalnothing.com"]
  gem.description   = %q{Rake tasks to assist with versioning and branch creation using the git workflow described in http://nvie.com/posts/a-successful-git-branching-model}
  gem.summary       = %q{Rake tasks for NVIE git workflow}
  gem.homepage      = "http://github.com/dnd/rake-nvie-git-workflow"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  #gem.add_dependency "bump", "~> 0.3.12"
end
