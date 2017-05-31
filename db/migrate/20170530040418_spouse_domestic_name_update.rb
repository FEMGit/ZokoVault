class SpouseDomesticNameUpdate < ActiveRecord::Migration
  def change
    Contact.where(:relationship => 'Spouse/Domestic Partner').update_all(:relationship => 'Spouse / Domestic Partner')
  end
end
