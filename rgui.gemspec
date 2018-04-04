# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'version'

Gem::Specification.new do |spec|
  spec.name          = "rgui"
  spec.version       = RGUI::VERSION
  spec.authors       = ["shitake"]
  spec.email         = ["z1422716486@hotmail.com"]

  spec.summary       = %q{an async event framework}
  spec.description   = %q{Svent is an async event framework implemented with Fiber.Used for game or GUI event handling. }
  spec.homepage      = "https://github.com/molingyu/svent"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"

end