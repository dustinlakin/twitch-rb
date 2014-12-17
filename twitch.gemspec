Gem::Specification.new do |s|
  s.name        = 'twitch'
  s.version     = '0.0.4'
  s.date        = Date.today.to_s
  s.summary     = "Twitch API"
  s.description = "Simplify Twitch's API for Ruby"
  s.authors     = ["Dustin Lakin"]
  s.email       = 'dustin.lakin@gmail.com'
  s.homepage    = "https://github.com/dustinlakin/twitch-rb"

  s.files       = ["lib/twitch.rb"]
  s.require_paths = ["lib"]
  
  s.add_dependency('httparty')
  s.add_dependency('json')
  s.add_development_dependency('rspec')
end
