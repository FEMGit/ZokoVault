class ReturnPathService
  def self.error_path(resource_owner, current_user, controller, action)
    return { controller: controller, action: action, layout: 'application',
             locals: { shared_user_id: "" }} unless shared_mode?(resource_owner, current_user)
    { controller: "shared_#{controller}", action: action, layout: 'shared_view',
             parameters: { shared_user: resource_owner,
                           shared_category_names: ResourceOwnerService.shared_category_names(resource_owner, current_user) },
             locals: { shared_user_id: resource_owner.id }}
  end
  
  def self.success_path(resource_owner, current_user, common_path, shared_view_path)
    return common_path unless shared_mode?(resource_owner, current_user)
    shared_view_path
  end
  
  def self.shared_user(path)
    return unless path[:parameters].present?
    path[:parameters][:shared_user]
  end
  
  def self.shared_category_names(path)
    return unless path[:parameters].present?
    path[:parameters][:shared_category_names]
  end
  
  private
  
  def self.shared_mode?(resource_owner, current_user)
    !current_user.eql? resource_owner
  end
end