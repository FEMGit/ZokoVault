load File.join(File.dirname(__FILE__),"seeds/categories.rb")
# Create users
emails = %w(admin@zokuvault.com)

users = emails.map do |email|
  user = User.find_or_initialize_by(email: email)
  user.password = user.password_confirmation = "password"
  user.confirmed_at = Time.now
  user.setup_complete = true
  user.build_user_profile(signed_terms_of_service_at: 1.day.ago, date_of_birth: (rand(40)+20).years.ago)
  user.save!(validate: false)
  user
end

user_contacts = users.map do |user|
  contacts = users.map do |user_as_contact|
    next if user == user_as_contact
    contact_type = Contact::CONTACT_TYPES.keys.sample
    relationship = Contact::CONTACT_TYPES[contact_type].sample

    Contact.find_or_create_by!(
      firstname: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      emailaddress: user_as_contact.email,
      phone: Faker::PhoneNumber.phone_number,
      birthdate: user_as_contact.date_of_birth,
      user: user,
      contact_type: contact_type,
      relationship: relationship
    )
  end

  [user, contacts]
end

#
# Create resources
#
resource_types = %i[will trust power_of_attorney health life_and_disability property_and_casualty]
resource_types.each do |resource_type|
  user_contacts.each do |user, contacts|
    resource = FactoryGirl.create(resource_type, user: user) || raise('hell')
    contacts.compact.each do |contact|
      user.shares.create!(contact: contact, shareable: resource)
    end
  end
end

categories = Category.all
categories.each do |category|
  user_contacts.each do |user, contacts|
    contacts.compact.each do |contact|
      user.shares.create!(contact: contact, shareable: category)
    end
  end
end