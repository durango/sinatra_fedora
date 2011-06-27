class Auth < Fedora
  # All of a sudden, our boss wanted all
  # authorization functions to point towards
  # /user instead of /auth!
  # url or namespace can be used here
  url '/user'

  get '/' do
    "User index (just a blank page)"
  end

  get '/list/?' do
    haml :list
  end
end