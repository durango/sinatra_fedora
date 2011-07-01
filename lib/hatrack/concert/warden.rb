# Link warden with the correct user id and function to grab user info
Warden::Manager.serialize_into_session{|user| user.id }
Warden::Manager.serialize_from_session{|id| User.get(id) }

Warden::Manager.before_failure do |env,opts|
	env['REQUEST_METHOD'] = "POST"
end

Warden::Strategies.add(:password) do
	def valid?
		params["email"] || params["password"]
	end 
	
	def authenticate!
		u = User.authenticate(params["email"], params["password"])
		if u.nil?
			fail!("Could not log in")
		else
			success!(u)
		end
	end 
end