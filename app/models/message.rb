class Message
  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :name, :email, :phone_number, :message_content, :preferred_contact_method

  validates :name, presence: true
  validates :email, presence: true
end
