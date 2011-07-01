require 'sinatra_fedora'
require 'datamapper'

class Fedora
  enable :sessions

  #DataMapper.setup(:default, 'adapter://user:password@host/db')

  set :views, File.dirname(__FILE__) + '/app/views'
  set :public, File.dirname(__FILE__) + '/public'

  configure(:development) do
    DataMapper::Logger.new($stdout, :debug)
  end

  Dir.glob('app/models/*.rb').each { |r| require File.expand_path(File.join(File.dirname(__FILE__), r)) }
  #DataMapper.finalize.auto_upgrade!

  Dir.glob('app/controllers/*.rb').each { |r| require File.expand_path(File.join(File.dirname(__FILE__), r)) }
end
