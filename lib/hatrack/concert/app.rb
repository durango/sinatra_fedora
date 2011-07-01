require 'sinatra_fedora'
require 'sass'
require 'haml'
require 'sinatra_warden'
require 'datamapper'
require 'rack-flash'

class Fedora
  enable :sessions
  register Sinatra::Warden
  use Rack::Flash

  #DataMapper.setup(:default, 'adapter://user:pass@host/db')

  set :views, File.dirname(__FILE__) + '/app/views'
  set :public, File.dirname(__FILE__) + '/public'

  # sinatra_warden helpers
  # for more info https://github.com/jsmestad/sinatra_warden
  set :auth_error_message, 'Invalid e-mail/password combination'
  set :auth_failure_path, '/login'
  set :auth_already_logged_in, '/account'

  # Don't forget to change this!
  use Rack::Session::Cookie, :secret => "my secret key!"

  configure(:development) do
    #DataMapper::Logger.new($stdout, :debug)
  end

  # Render .css files
  get '/:file.css' do |file|
    content_type :css
    response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
    if File.file?(File.join(settings.views, "#{file}.scss"))
      scss file.to_sym
    else
      not_found
    end
  end

  Dir.glob('app/models/*.rb').each { |r| require File.expand_path(File.join(File.dirname(__FILE__), r)) }
  DataMapper.finalize.auto_upgrade!

  Dir.glob('app/controllers/*.rb').each { |r| require File.expand_path(File.join(File.dirname(__FILE__), r)) }

  # Warden helper file
  require File.dirname(__FILE__) + '/warden.rb'

  # Add warden strategies here
	use Warden::Manager do |manager|
		manager.default_strategies :password
		manager.failure_app = Fedora
	end
end