class OnlineAccount < ActiveRecord::Base
  scope :for_user, ->(user) { where(user: user) }
  
  belongs_to :category
  belongs_to :user
  
  has_many :shares, as: :shareable,  dependent: :destroy
  has_many :share_with_contacts, 
    through: :shares,
    source: :contact
    
  belongs_to :per_user_encryption_key, inverse_of: :online_accounts
  
  validates_length_of :website, :maximum => (ApplicationController.helpers.get_max_length(:web) + ApplicationController.helpers.get_max_length(:web_prefix))
  validates_length_of :username, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :notes, :maximum => ApplicationController.helpers.get_max_length(:notes)
  
  validates_format_of :website,
                      :with => Validation::WEB_ADDRESS_URL,
                      :message => "Please enter a valid url (starts with 'http://' or 'https://')",
                      :allow_blank => true
  
  validates_length_of :password, :maximum => 500
  
  before_save { self.category = Category.fetch("online accounts") }
  
  class CryptographyError < StandardError; end
  
  def decrypted_password
    @decrypted_password ||= begin
      if !per_user_encryption_key
        raise CryptographyError, "online_account #{id} has no per_user key!"
      elsif per_user_encryption_key.user_id != user_id
        raise CryptographyError, "they key for online_account #{id} has the wrong user"
      else
        PasswordService.for_per_user_key(per_user_encryption_key).decrypt_password(password)
      end
    end
  end
end
