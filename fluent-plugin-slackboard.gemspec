# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-slackboard"
  spec.version       = "0.0.1"
  spec.authors       = ["Tatsuhiko Kubo"]
  spec.email         = ["cubicdaiya@gmail.com"]
  spec.summary       = %q{plugin for proxying message to slackboard}
  spec.description   = %q{plugin for proxying message to slackboard}
  spec.homepage      = "https://github.com/cubicdaiya/fluent-plugin-slackboard"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
