# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'sinatra_fedora'
  s.version     = '1.2'
  s.summary     = "An even classier way to use Sinatra."
  s.description = "Converts class names intro controllers and automatically maps them. Same thing with views and both, views and controllers, can be configured to your liking. It combines the best of both Padrino and Sinatra."
  s.authors     = ["Daniel Durante"]
  s.email       = 'officedebo@gmail.com'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(COPYING README.rdoc)
  s.executables = ["fedora"]
  s.require_paths = ["lib"]
  s.homepage    = 'https://github.com/durango/sinatra_fedora'
  s.add_dependency 'sinatra', '>= 1.0'
  s.license = 'MIT'
  s.date = Time.now.strftime("%Y-%m-%d")
  s.required_rubygems_version = ">= 1.3.6"
end
