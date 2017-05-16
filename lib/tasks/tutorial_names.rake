namespace :tutorial_names do
  task :update => :environment do
    insurance = Tutorial.find_by(name: 'Insurance')
    insurance.update(name: 'I have Insurance.')

    home = Tutorial.find_by(name: 'Home')
    home.update(name: 'I own a house or property.')

    primary_contact = Tutorial.find_by(name: 'Add Primary Contact')
    primary_contact.update(name: 'I have a family.')

    vehicle = Tutorial.find_by(name: 'Vehicle')
    vehicle.update(name: 'I own a vehicle.')

    trust_tutorial = Tutorial.find_by(name: 'Trust')
    trust_tutorial.update(name: 'I have a trust.')
  end
end
