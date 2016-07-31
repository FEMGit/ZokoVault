json.array!(@contacts) do |contact|
  json.extract! contact, :id, :firstname, :lastname, :emailaddress, :phone, :category, :relationship, :beneficiarytype, :ssn, :birthdate, :address, :zipcode, :state, :notes, :avatarcolor, :photourl, :businessname, :businesswebaddress, :businessphone, :businessfax
  json.url contact_url(contact, format: :json)
end
