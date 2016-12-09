class UserActivity < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  scope :for_date, ->(date) { where(login_date: date) }
  scope :date_range, ->(start_date, end_date) { where(login_date: start_date..end_date) }

  belongs_to :user
end
