Gem::Specification.new do |s|
  s.name        = 'twitch'
  s.version     = '0.0.2'
  s.date        = '2013-01-30'
  s.summary     = "Twitch API"
  s.description = "Simplify Twitch's API for Ruby"
  s.authors     = ["Dustin Lakin"]
  s.email       = 'dustin.lakin@gmail.com'
  s.homepage    = "https://github.com/dustinlakin/twitch-rb"
  s.files       = ["lib/twitch.rb"]
  s.require_paths = ["lib"]
  s.add_dependency('curb')
  s.add_dependency('json')
end
