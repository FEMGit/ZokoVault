require 'securerandom'

class MultifactorPhoneCode < ActiveRecord::Base
  scope :latest, -> { order(created_at: :desc).limit(1) }

  def self.generate_for(user)
    create!(user_id: user.id, code: random_code)
  end

  def self.verify_latest(user, code)
    latest.where(user_id: user.id).pluck(:code).first == code
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
