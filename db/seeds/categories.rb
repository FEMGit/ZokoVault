["Wills - POA",
 "Trusts & Entities",
 "Insurance",
 "Vault",
 "Taxes",
 "Healthcare Choices",
 "Final Wishes",
 "Trusts & Entities",
 "Wills - POA",
 "Financial Information",
 "My Profile",
 "Documents"].inject({}) do |hsh, name|
   next hsh if Category.exists? name: name
   category = Category.create! name: name, description: name
   hsh.merge(name => category)
end
