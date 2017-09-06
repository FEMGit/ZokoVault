class OnlineAccount < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  
  belongs_to :category
  belongs_to :user
  
  has_many :shares, as: :shareable,  dependent: :destroy
  has_many :share_with_contacts, 
    through: :shares,
    source: :contact
  
  validates_length_of :website, :maximum => (ApplicationController.helpers.get_max_length(:web) + ApplicationController.helpers.get_max_length(:web_prefix))
  validates_length_of :username, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  
  validates_format_of :website,
                      :with => Validation::WEB_ADDRESS_URL,
                      :message => "Please enter a valid url (starts with 'http://' or 'https://')",
                      :allow_blank => true
  
  validates_length_of :password, :maximum => 500
  
  before_save { self.category = Category.fetch("online accounts") }  
end
