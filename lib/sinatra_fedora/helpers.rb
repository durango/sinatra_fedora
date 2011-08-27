module Sinatra
  # Simple way to escape HTML (method 'h')
  module HTMLEscapeHelper
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  # partials helper
  module Partials
    def partial(page, options = {})
      options[:views_directory] ||= options[:via]
      options[:layout] ||= false
      render (options[:engine] ||= "haml"), page.to_sym, options
    end
  end

  # link_to helper
  module LinkHelper
    extend Memoizable

    def get_namespace(klass)
      begin
        Object.const_get(klass).namespace
      rescue
        klass
      end
    end

    def link_to(link, disable=false)
      if disable
        return link
      end

      _class = link.gsub(/^\/([\w\d]+)/, '\1').split('/')
      _name = get_namespace _class[0].capitalize
      _name + _class.join('/').gsub(_class[0], '')
    end
    # Cache the namespace to save time
    memoize :get_namespace
  end

  module Templates
    def render(engine, data, options={}, locals={}, &block)
      # Merge app-level options
      options = settings.send(engine).merge(options) if settings.respond_to?(engine)
      options[:outvar]           ||= '@_out_buf'
      options[:default_encoding] ||= settings.default_encoding

      # Extract generic options
      locals          = options.delete(:locals) || locals         || {}
      views           = options.delete(:views)  || settings.views || "./views"
      @default_layout = :layout if @default_layout.nil?
      layout          = options.delete(:layout)
      eat_errors      = layout.nil?
      layout          = @default_layout if layout.nil? or layout == true
      content_type    = options.delete(:content_type)  || options.delete(:default_content_type)
      layout_engine   = options.delete(:layout_engine) || engine
      scope           = options.delete(:scope)         || self

      # Fedora views
      if data != :layout and options[:views_directory].nil?
        look_in = (scope.class.views_from || scope.class.name.downcase)
        data = "#{look_in}/#{data.to_s}".to_sym
      end

      # Compile and render template
      layout_was      = @default_layout
      @default_layout = false
      template        = compile_template(engine, data, options, views)
      output          = template.render(scope, locals, &block)
      @default_layout = layout_was

      # Render layout
      if layout
        options = options.merge(:views => views, :layout => false, :eat_errors => eat_errors, :scope => scope)
        catch(:layout_missing) { return render(layout_engine, layout, options, locals) { output } }
      end

      output.extend(ContentTyped).content_type = content_type if content_type
      output
    end
  end
end