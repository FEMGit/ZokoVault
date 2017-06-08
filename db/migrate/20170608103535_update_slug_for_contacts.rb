class UpdateSlugForContacts < ActiveRecord::Migration
  def change
    Contact.find_each(:batch_size => 1000) do |contact|
      next unless contact.user && contact.valid?
      contact.save!
    end
  end
end
