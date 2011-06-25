class Auth < Fedora
	# All of a sudden, our Boss wanted all
	# authorization functions to point towards
	# /user instead of /auth!
	namespace '/user'

	get '/' do
		"User index"
	end

	get '/list' do
		"List your users here"
	end
end