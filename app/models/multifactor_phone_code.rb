require 'securerandom'

class MultifactorPhoneCode < ActiveRecord::Base
  scope :not_expired, ->(at = Time.current) do
    where("created_at > ?", at - 5.minutes)
  end

  def self.generate_for(user)
    create!(user_id: user.id, code: random_code)
  end

  def self.verify(user:, code:)
    return false if user.blank? || user.id.blank? || code.blank?
    available = not_expired.
                where(user_id: user.id).
                order(created_at: :desc).
                limit(5).to_a
    available.any?{ |mf| mf.code == code }.tap do
      # TODO track failed login attempts
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
