module BreadcrumbsCacheModule
  def self.included(base)
    base.before_filter :cache_breadcrumbs_write
  end

  def cache_key
    return 'breadcrumbs-shared' if @shared_user.present?
    'breadcrumbs'
  end

  def cache_breadcrumbs_write
    Rails.cache.delete(cache_key)
    return unless @breadcrumbs.present?
    @breadcrumbs.each { |x| x.options[:user] = current_user }
    Rails.cache.write(cache_key, @breadcrumbs)
  end

  def cache_breadcrumbs_pop(user, shared_user = nil)
    @shared_user = shared_user
    breadcrumbs = Rails.cache.read(cache_key)
    return if breadcrumbs.nil?
    breadcrumbs = breadcrumbs.reject { |x| x.options[:user] != user }
    Rails.cache.delete(cache_key)
    breadcrumbs
  end

  def cache_temp_breadcrumbs_write(breadcrumbs, current_user)
    Rails.cache.delete(temp_cache_key)
    return unless breadcrumbs.present?
    breadcrumbs.each { |x| x.options[:user] = current_user }
    Rails.cache.write(temp_cache_key, breadcrumbs)
  end

  def cache_temp_breadcrumbs_pop(user, shared_user = nil)
    @shared_user = shared_user
    breadcrumbs_cached = Rails.cache.read(temp_cache_key)
    return if breadcrumbs_cached.nil?
    breadcrumbs_cached
  end

  def cache_temp_breadcrumbs_delete
    Rails.cache.delete(temp_cache_key)
  end

  module_function :cache_breadcrumbs_pop, :cache_key,
                  :cache_temp_breadcrumbs_write, :cache_temp_breadcrumbs_pop,
                  :cache_temp_breadcrumbs_delete, :cache_breadcrumbs_write

  private

  def self.temp_cache_key
    return 'temp-breadcrumbs-shared' if @shared_user.present?
    'temp-breadcrumbs'
  end
end
