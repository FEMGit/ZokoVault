class UpdateInsuranceSubtutorialNames < ActiveRecord::Migration
  def change
    Subtutorial.find_by(name: 'I have Life or Disability Insurance.').update(:name => 'My life or disability insurance.')
    Subtutorial.find_by(name: 'I have Property Insurance.').update(:name => 'My property insurance.')
    Subtutorial.find_by(name: 'I have Health Insurance.').update(:name => 'My health insurance.')
    Subtutorial.find_by(name: 'I have an Insurance Broker.').update(:name => 'My insurance broker(s).')
  end
end
