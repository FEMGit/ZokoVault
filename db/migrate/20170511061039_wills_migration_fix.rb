class WillsMigrationFix < ActiveRecord::Migration
  def change
    card_document_will_ids = CardDocument.where(object_type: 'Will').map(&:card_id)
    Will.select { |w| !card_document_will_ids.include? w.id }.each do |will|
      if will.user.present?
        CardDocument.create!(object_type: 'Will', category: Category.fetch('wills - poa'), user_id: will.user_id, card_id: will.id)
      end
    end
  end
end
