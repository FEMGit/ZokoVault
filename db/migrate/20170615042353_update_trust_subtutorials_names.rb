class UpdateTrustSubtutorialsNames < ActiveRecord::Migration
  def change
    Subtutorial.find_by(name: 'I have a trust.').update(:name => 'My trust.')
    Subtutorial.find_by(name: 'I have a family entity.').update(:name => 'My family entity.')
    Subtutorial.find_by(name: 'I have a trust or entity attorney.').update(:name => 'My attorney.')
  end
end
