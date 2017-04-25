class RemoveDuplicates < ActiveRecord::Migration
  def change
      document_associated_ids = Document.all.map(&:card_document_id).compact
    %w(PowerOfAttorneyContact Will Trust Entity).each do |object_type|
      card_document_poa_duplicate = CardDocument.select { |c| c.object_type = object_type }
                                                .group_by { |c| c.card_id }
                                                .select { |k, v| v.count > 1 }

      ids_to_destroy = []
      card_document_poa_duplicate.values.each do |card_documents|
        card_documents.each do |card_document|
          if (document_associated_ids.include? card_document.id) ||
             ((card_documents.map(&:id) - document_associated_ids).count != 1 && card_documents.last == card_document)
            next
          else
            ids_to_destroy << card_document.id
          end
        end
      end
      CardDocument.where(:id => ids_to_destroy).destroy_all
    end
  end
end
