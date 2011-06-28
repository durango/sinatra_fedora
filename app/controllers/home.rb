class Home < Fedora
  # Set as the root URL otherwise
  # the url will default to /home
  # (class name lowercased)
  url '/'

  # views_from can tell Fedora which
  # folder in :views you want to use
  # for all actions in this class
  # (:views_directory overrides this)
  views_from '/'

  get '/' do
    haml :index
  end

  get '/welcome/?' do
    h "Try me too! <This is escaped!>"
  end

  get '/list/?' do
    haml :list
  end
end