class UserTraffic < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  scope :shared_traffic, ->(user) { where(shared_user_id: user.id) }

  belongs_to :user
  before_destroy :remove_shared_with_id_rows
  
  private
  
  def remove_shared_with_id_rows
    user_id = self.user_id
    return unless user_id.present?
    UserTraffic.where(shared_user_id: user_id).update_all(:page_url => '/', shared_user_id: nil)
  end
end
