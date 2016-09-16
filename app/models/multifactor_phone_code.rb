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
    rand(10_000..99_999)
  end
end
