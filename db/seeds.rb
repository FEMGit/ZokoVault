# Create users
<<<<<<< 5359d8f6e79ea63dcf961cde872ddd7562b108e8

emails = %w[ admin@zokuvault.com user@zokuvault.com user@example.com ]
=======
>>>>>>> Merge conflict resolve

emails = %w[ admin@zokuvault.com user@zokuvault.com user@example.com ]

users = emails.map do |email|
  user = User.find_or_initialize_by(email: email)
  user.password = user.password_confirmation = "password"
  user.confirmed_at = Time.now
  user.save
  user
end

user_contacts = users.map do |user|
  contacts = 10.times.map do 
    contact_type = Contact::CONTACT_TYPES.keys.sample
    relationship = Contact::CONTACT_TYPES[contact_type].sample

    Contact.find_or_create_by(
      firstname: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      emailaddress: Faker::Internet.free_email,
      phone: Faker::PhoneNumber.phone_number,
      birthdate: Faker::Date.between(60.years.ago, 20.years.ago),
      user: user,
      contact_type: contact_type,
      relationship: relationship
    )
  end

user_contacts = users.map do |user|
  contacts = 10.times.map do 
    contact_type = Contact::CONTACT_TYPES.keys.sample
    relationship = Contact::CONTACT_TYPES[contact_type].sample

    Contact.find_or_create_by(
      firstname: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      emailaddress: Faker::Internet.free_email,
      phone: Faker::PhoneNumber.phone_number,
      birthdate: Faker::Date.between(60.years.ago, 20.years.ago),
      user: user,
      contact_type: contact_type,
      relationship: relationship
    )
  end

  [user, contacts]
end

#
# Create a vendor per contact
#
groups = %w[life property health]

>>>>>>> Merge conflict resolve
user_contacts.each do |user, contacts|
  contacts.each do |contact|
    Vendor.create!(
      category: 'insurance',
      group: groups.sample,
      name: Faker::Name.name,
      webaddress: Faker::Internet.url,
      phone: Faker::PhoneNumber.phone_number,
      contact: contact,
      user: user
    )
  end
end
