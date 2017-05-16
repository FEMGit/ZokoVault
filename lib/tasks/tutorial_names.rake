namespace :tutorial_names do
  task :update => :environment do
    insurance = Tutorial.find_by(name: 'Insurance')
    insurance.update(name: 'I have Insurance.', slug: 'Insurance')

    home = Tutorial.find_by(name: 'Home')
    home.update(name: 'I own a house or property.', slug: 'Home')

    primary_contact = Tutorial.find_by(name: 'Add Primary Contact')
    primary_contact.update(name: 'I have a family.', slug: 'Add Primary Contact')

    vehicle = Tutorial.find_by(name: 'Vehicle')
    vehicle.update(name: 'I own a vehicle.', slug: 'Vehicle')

    trust_tutorial = Tutorial.find_by(name: 'Trust')
    trust_tutorial.update(name: 'I have a trust.', slug: 'Trust')
  end
end
