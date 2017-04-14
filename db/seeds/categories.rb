["Wills - Trusts - Legal",
 "Insurance",
 "Vault",
 "Taxes",
 "Healthcare Choices",
 "Final Wishes",
 "Trusts & Entities",
 "Wills - POA",
 "Financial Information",
 "My Profile"].inject({}) do |hsh, name|
   next if Category.exists? name: name
   category = Category.create! name: name, description: name
   hsh.merge(name => category)
end
