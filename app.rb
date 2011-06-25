require 'sinatra/base'
require 'lib/sinatra_fedora'

class Fedora
	enable :sessions

	set :views, File.dirname(__FILE__) + '/app/views'
	set :public, File.dirname(__FILE__) + '/public'

	Dir.glob('app/models/*.rb').each { |r| require File.expand_path(File.join(File.dirname(__FILE__), r)) }
	Dir.glob('app/controllers/*.rb').each { |r| require File.expand_path(File.join(File.dirname(__FILE__), r)) }
end
