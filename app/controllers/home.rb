class Home < Fedora
	# Set as the root URL otherwise
	# the url will default to /home
	# (class name lowercased)
	namespace '/'

	get '/' do
		"Hello world!"
	end
	
	get '/welcome' do
		"Try me too!"
	end
end