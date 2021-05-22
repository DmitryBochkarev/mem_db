# frozen_string_literal: true

require_relative "lib/mem_db/version"

Gem::Specification.new do |spec|
  spec.name          = "mem_db"
  spec.version       = MemDB::VERSION
  spec.authors       = ["Dmitry Bochkarev"]
  spec.email         = ["dimabochkarev@gmail.com"]

  spec.summary       = "MemDB is embedded database"
  spec.description   = "MemDB is embedded database"
  spec.homepage      = "https://github.com/DmitryBochkarev/mem_db"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/DmitryBochkarev/mem_db"
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
