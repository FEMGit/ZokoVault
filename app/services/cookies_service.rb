module CookiesService
  def self.save(key, value)
    Rails.cache.write(key, value)
  end
  
  def self.pop(key)
    value = Rails.cache.read(key)
    Rails.cache.delete(key)
    value
  end
end
