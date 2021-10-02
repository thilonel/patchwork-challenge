# coding: utf-8
Gem::Specification.new do |spec|
  spec.name = 'nomics_client'
  spec.version = "0.0.1"
  spec.authors = ['Daniel Nagy']
  spec.email = ['naitodai@gmail.com']

  summary = 'Ruby Client SDK for Nomics API'
  spec.summary = summary
  spec.description = summary

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.license = 'Apache License 2.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "dotenv", "~> 2.7"
end
