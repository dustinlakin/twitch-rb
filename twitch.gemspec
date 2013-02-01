Gem::Specification.new do |s|
  s.name        = 'twitch'
  s.version     = '0.0.1'
  s.date        = '2013-01-30'
  s.summary     = "Twitch API"
  s.description = "Simplify Twitch's API for Ruby"
  s.authors     = ["Dustin Lakin"]
  s.email       = 'dustin.lakin@gmail.com'
  s.files       = ["lib/twitch.rb"]
  s.require_paths = ["lib"]
  s.add_dependency('curb')
  s.add_dependency('json')
  s.homepage    = "http://lak.in/"
end