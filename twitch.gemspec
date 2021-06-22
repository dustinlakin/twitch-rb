# frozen_string_literal: true

require_relative 'lib/twitch/version'

Gem::Specification.new do |s|
  s.name        = 'twitch'
  s.version     = Twitch::VERSION
  s.summary     = 'Twitch API'
  s.description = "Simplify Twitch's API for Ruby"
  s.authors     = ['Dustin Lakin']
  s.email       = 'dustin.lakin@gmail.com'
  s.homepage    = 'https://github.com/dustinlakin/twitch-rb'

  s.files       = Dir['lib/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.4', '< 4'

  s.add_runtime_dependency 'faraday', '~> 1.0'
  s.add_runtime_dependency 'faraday_middleware', '~> 1.0'
  s.add_runtime_dependency 'retriable', '~> 3.0'
  s.add_runtime_dependency 'twitch_oauth2', '~> 0.2.0'

  s.add_development_dependency 'pry-byebug', '~> 3.9'
  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'rubocop', '~> 0.89.0'
  s.add_development_dependency 'rubocop-performance', '~> 1.5'
  s.add_development_dependency 'rubocop-rspec', '~> 1.38'
  s.add_development_dependency 'simplecov', '~> 0.18.0'
  s.add_development_dependency 'vcr', '~> 6.0'
end
