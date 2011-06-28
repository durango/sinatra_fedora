Gem::Specification.new do |s|
  s.name        = 'sinatra_fedora'
  s.version     = '1.0.1'
  s.summary     = "An even classier way to use Sinatra."
  s.description = "Converts class names intro controllers and automatically maps them. Same thing with views and both, views and controllers, can be configured to your liking. It combines the best of both Padrino and Sinatra."
  s.authors     = ["Daniel Durante"]
  s.email       = 'officedebo@gmail.com'
  s.files       = ["lib/sinatra_fedora.rb","lib/sinatra_fedora/fedora.rb"]
  s.require_paths = ["lib"]
  s.homepage    = 'https://github.com/durango/sinatra_fedora'
  s.add_development_dependency 'sinatra', '>= 1.0'
  s.license = 'MIT'
end
