class Message
  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :name, :email, :phone_number, :message_content, :preferred_contact_method

  validates :name, presence: true
  validates :email, presence: true
  validates :email, :email_format => { :message => "Email should contain @ and domain like '.com" }
  validate :email_is_valid?
  
  private
  
  def email_is_valid?
    MailService.email_is_valid?(email, errors)
  end
end
