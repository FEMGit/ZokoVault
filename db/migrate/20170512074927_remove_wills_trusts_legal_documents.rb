class RemoveWillsTrustsLegalDocuments < ActiveRecord::Migration
  def change
    Document.where(:category => 'Wills - Trusts - Legal').destroy_all
  end
end
