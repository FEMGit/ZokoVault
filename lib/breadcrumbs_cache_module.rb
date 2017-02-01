module BreadcrumbsCacheModule
  def self.included(base)
    base.before_filter :cache_breadcrumbs_write
  end
  
  def cache_breadcrumbs_write
    Rails.cache.delete('breadcrumbs')
    return unless @breadcrumbs.present?
    @breadcrumbs.each { |x| x.options[:user] = (@shared_user || current_user) }
    Rails.cache.write('breadcrumbs', @breadcrumbs)
  end
  
  def cache_breadcrumbs_pop(user)
    breadcrumbs = Rails.cache.read('breadcrumbs')
    breadcrumbs = breadcrumbs.reject { |x| x.options[:user] != user }
    Rails.cache.delete('breadcrumbs')
    breadcrumbs
  end
  
  module_function :cache_breadcrumbs_pop
end