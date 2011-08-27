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