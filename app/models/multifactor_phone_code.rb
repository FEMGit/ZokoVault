require 'securerandom'

class MultifactorPhoneCode < ActiveRecord::Base
  MAX_ACTIVE = 5
  
  validates :user_id, presence: true
  validates :code, presence: true
  validates :phone_number, presence: true

  scope :not_expired, ->(at = Time.current) do
    where("created_at > ?", at - 5.minutes)
  end

  def self.can_make_more?(user)
    return false if user.blank? || user.id.blank?
    not_expired.where(user_id: user.id).count < MAX_ACTIVE
  end

  def self.generate_for(user:, phone_number:)
    new.tap do |record|
      record.user_id = user.id
      record.code = random_code
      record.phone_number = phone_number
      record.save!
    end
  end

  def self.verify(user:, code:, phone_number:)
    return false if user.blank? || user.id.blank? ||
                    code.blank? || phone_number.blank?
    code_string = code.to_s
    available = not_expired.
                where(user_id: user.id).
                order(created_at: :desc).
                limit(MAX_ACTIVE).to_a
    available.any? do |mf|
      mf.code == code_string && mf.phone_number == phone_number
    end
  end

  private

  # Generate random 5 number code
  def self.random_code
    int = SecureRandom.hex(4).to_i(16)
    return random_code if int >= 4294890000
    @code_range ||= (10_000..99_999).to_a.freeze
    @code_range[int % 90_000]
  end

end
