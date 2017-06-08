class UpdateDocumentsSlug < ActiveRecord::Migration
  def change
    Document.find_each(:batch_size => 1000) do |document|
      document.save!
    end
  end
end
