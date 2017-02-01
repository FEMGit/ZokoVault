class Category < ActiveRecord::Base
  after_save { self.class.identity_map(:bust_cache) }
  after_destroy { self.class.identity_map(:bust_cache) }

  validates :name, presence: true, uniqueness: true

  def self.fetch(name)
    identity_map.fetch(name, nil)
  end

  def self.identity_map(bust_cache = false)
    @identity_map = nil if bust_cache
    @identity_map ||= all.map { |c| [c.name.downcase.freeze, c] }.to_h
  end
end
