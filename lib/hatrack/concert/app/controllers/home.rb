class Home < Fedora
  # Set as the root URL otherwise
  # the url will default to /home
  # (class name lowercased)
  url '/'

  # views_from tells Fedora which
  # folder in :views you want to use
  # for all actions in this class
  # (:views_directory overrides this)
  views_from '/'

  get '/' do
    haml :index
  end
end