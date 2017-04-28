class PrimarySharedUser < ActiveRecord::Base
  self.primary_key = :owning_user_id

  belongs_to :owning_user, class_name: 'User'
  belongs_to :shared_with_user, class_name: 'User'

  validates :owning_user_id, presence: true, uniqueness: true
  validates :shared_with_user_id, presence: true
end
