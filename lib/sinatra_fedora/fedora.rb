=begin
 fedora.rb - Sinatra::Fedora class
 *
 * Copyright (c) 2011, Daniel Durante <officedebo at gmail dot com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of Redis nor the names of its contributors may be used
 *     to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
=end

require 'sinatra/base'

# Memoizable code for caching link_to objects
# see http://snippets.dzone.com/posts/show/5300
module Memoizable
  # Store for cached values.
  CACHE = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = {}}} # 3 level hash; CACHE[:foo][:bar][:yelp]
  
  # Memoize the given method(s).
  def memoize(*names)
    names.each do |name|
      unmemoized = "__unmemoized_#{name}"
      
      class_eval %Q{
        alias   :#{unmemoized} :#{name}
        private :#{unmemoized}
        def #{name}(*args)
          cache = CACHE[self][#{name.inspect}]
          cache.has_key?(args) ? cache[args] : (cache[args] = send(:#{unmemoized}, *args))
        end
      }
    end
  end
  
  # Flush cached return values.
  def flush_memos
    CACHE.clear
  end
  module_function :flush_memos
end

module Sinatra
  # simple way to escape HTML (method 'h')
  module HTMLEscapeHelper
    def h(text)
      Rack::Utils.escape_html(text)
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
    # cache the namespace to save time
    memoize :get_namespace
  end

  module Templates
    def render(engine, data, options={}, locals={}, &block)
      # merge app-level options
      options = settings.send(engine).merge(options) if settings.respond_to?(engine)
      options[:outvar]           ||= '@_out_buf'
      options[:default_encoding] ||= settings.default_encoding

      # extract generic options
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
        look_in = (scope.class.name.downcase || scope.class.views_from) if scope.class.views_from.nil?
        data = "#{look_in}/#{data.to_s}".to_sym
      end

      # compile and render template
      layout_was      = @default_layout
      @default_layout = false
      template        = compile_template(engine, data, options, views)
      output          = template.render(scope, locals, &block)
      @default_layout = layout_was

      # render layout
      if layout
        options = options.merge(:views => views, :layout => false, :eat_errors => eat_errors, :scope => scope)
        catch(:layout_missing) { return render(layout_engine, layout, options, locals) { output } }
      end

      output.extend(ContentTyped).content_type = content_type if content_type
      output
    end
  end
end

class Fedora < Sinatra::Base
  helpers Sinatra::HTMLEscapeHelper
  helpers Sinatra::LinkHelper

  def self.inherited(klass)
    super
    descendents.push(klass)
  end

  def self.descendents
    @descendents ||= []
  end

  def self.map
    Hash[descendents.map { |d| [(d.namespace), d] }]
  end

  def self.views_from(value=nil)
    return (@views_from || nil) if value.nil?
    @views_from = value
  end

  def self.namespace(value=nil)
    return (@namespace || "/#{name}") if value.nil?
    @namespace = value
  end

  def self.url(value=nil)
    self.namespace value
  end
end