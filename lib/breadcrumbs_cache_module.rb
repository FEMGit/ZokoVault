module BreadcrumbsCacheModule
  def self.included(base)
    base.before_filter :cache_breadcrumbs_write
  end
  
  def cache_breadcrumbs_write
    Rails.cache.delete('breadcrumbs')
    Rails.cache.write('breadcrumbs', @breadcrumbs)
  end
  
  def cache_breadcrumbs_pop
    breadcrumbs = Rails.cache.read('breadcrumbs')
    Rails.cache.delete('breadcrumbs')
    breadcrumbs
  end
  
  module_function :cache_breadcrumbs_pop
end