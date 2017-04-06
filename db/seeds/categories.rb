["Wills - POA",
 "Trusts & Entities",
 "Insurance",
 "Vault",
 "Taxes",
 "Healthcare Choices",
 "Final Wishes"].inject({}) do |hsh, name|
   next if Category.exists? name: name
   category = Category.create! name: name, description: name
   hsh.merge(name => category)
end
