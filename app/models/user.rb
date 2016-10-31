class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable, :registerable,
         :recoverable, :timeoutable, :trackable, :validatable


  has_one :user_profile, -> { order("created_at DESC") }
  accepts_nested_attributes_for :user_profile, update_only: true

  delegate :mfa_frequency, :name, :phone_number, :signed_terms_of_service?, to: :user_profile

  def mfa_verify?
    case mfa_frequency
    when "never"
      false
    when "always"
      true
    else 
      current_sign_in_ip != last_sign_in_ip
    end
  end
end
