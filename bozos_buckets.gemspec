# frozen_string_literal: true

require_relative 'lib/bozos_buckets/version'

Gem::Specification.new do |s|
  s.name        = 'bozos_buckets'
  s.version     = BozosBuckets::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'A low overhead implementation of a token bucket'
  s.description = <<-DOC
    A low overhead implementation of a token bucket for rate limiting.
    Does not use an array or linked list, and therefore has a tiny memory footprint
  DOC
  s.authors     = ['Alex Glover']
  s.email       = 'alexdglover@gmail.com'
  s.files       = Dir['lib/**/*.rb']
  # No specific version requirements, but you should be on something newer than 2 right?
  s.required_ruby_version = '>= 2.5.0'
  s.add_development_dependency 'rspec'
end
