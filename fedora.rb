require 'sinatra/base'

class Fedora < Sinatra::Base
  def self.inherited(klass)
    super
    descendents.push(klass)
  end

  def self.descendents
     @descendents ||= []
  end

  def self.map
    Hash[descendents.map { |d| [d.namespace, d] }]
  end

  def self.namespace(value=nil)
    return (@namespace || "/#{name}") if value.nil?
    @namespace = value
  end
end

# Generally, I like to separate the main Fedora class
# and the what would be "class MyApp < Sinatra::Base" class
require 'app'