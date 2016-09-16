class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable, :registerable,
         :recoverable, :timeoutable, :trackable, :validatable


  has_one :user_profile
  accepts_nested_attributes_for :user_profile

  delegate :name, :phone_number, :signed_terms_of_service?, to: :user_profile
end
