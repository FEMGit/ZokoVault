#
# Create users
#
# emails = %w[ admin@zokuvault.com user@zokuvault.com user@example.com ]

# users = emails.map do |email|
#   user = User.find_or_initialize_by(email: email)
#   user.password = user.password_confirmation = "password"
#   user.confirmed_at = Time.now
#   user.save
#   user
# end

# #
# # Create a few contacts for each user
# #
# categories = %w[work sports social family religious in-law]

# user_contacts = users.map do |user|
#   contacts = 10.times.map do 
#     Contact.find_or_create_by(
#       firstname: Faker::Name.first_name,
#       lastname: Faker::Name.last_name,
#       emailaddress: Faker::Internet.free_email,
#       phone: Faker::PhoneNumber.phone_number,
#       birthdate: Faker::Date.between(60.years.ago, 20.years.ago),
#       user: user,
#       category: categories.sample
#     )
#   end

#   [user, contacts]
# end

# #
# # Create a vendor per contact
# #
# groups = %w[life property health]

# user_contacts.each do |user, contacts|
#   contacts.each do |contact|
#     Vendor.create!(
#       category: 'insurance',
#       group: groups.sample,
#       name: Faker::Name.name,
#       webaddress: Faker::Internet.url,
#       phone: Faker::PhoneNumber.phone_number,
#       contact: contact,
#       user: user
#     )
#   end
# end

{ 'professional' => ['Clergy',
'Philosophers',
'Anesthesiologists',
'Audiologists',
'Chiropractors',
'Dentists',
'Dietitians',
'Nurses',
'Optometrists',
'Pharmacists',
'Physical therapists',
'Physicians',
'Podiatrists',
'Psychologists',
'Radiographers',
'Radiotherapists',
'Speech-language pathologists',
'Surgeons',
'Veterinarians',
'Accountants',
'Actuaries',
'Airline Pilots',
'Architects',
'Engineers',
'Linguistics',
'Translators',
'Interpreters',
'Surveyors',
'Military',
'Lawyers',
'Social Workers',
'Police officer',
'Health inspector',
'Park ranger'],
'personal' => ['Family',
'Single parent',
'Nuclear family (immediate family)',
'Spouse',
'Husband',
'Wife',
'Parent',
'Father',
'Mother',
'Child',
'Son',
'Daughter',
'Sibling',
'Brother',
'Sister',
'Extended family',
'Grandparent',
'Grandfather',
'Grandmother',
'Grandson',
'Granddaughter',
'Uncle',
'Aunt',
'Cousin',
'Nephew',
'Niece',
'Family-in-law',
'Father-in-law',
'Mother-in-law',
'Brother-in-law',
'Sister-in-law']
}.each do |type, names|
  names.each { |name| Relationship.create(name: name, type: type) }
end
