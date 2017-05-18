namespace :tutorial_names do
  task :update => :environment do
    Tutorial.all.each do |tuto|
        tuto.description = tuto.name
        tuto.save
    end
    Tutorial.find_by(name: 'I have Insurance.').update name: 'Insurance'
    Tutorial.find_by(name: 'I own a house or property.').update name: 'Home'
    Tutorial.find_by(name: 'I have a family.').update name: 'Add Primary Contact'
    Tutorial.find_by(name: 'I own a vehicle.').update name: 'Vehicle'
    Tutorial.find_by(name: 'I have a trust.').update name: 'Trust'
  end
end
