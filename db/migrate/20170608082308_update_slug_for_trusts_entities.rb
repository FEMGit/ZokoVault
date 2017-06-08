class UpdateSlugForTrustsEntities < ActiveRecord::Migration
  def change
    Trust.find_each(:batch_size => 1000) do |trust|
      next unless trust.user
      trust.save!
    end
    
    Entity.find_each(:batch_size => 1000) do |entity|
      next unless entity.user
      entity.save!
    end
  end
end
