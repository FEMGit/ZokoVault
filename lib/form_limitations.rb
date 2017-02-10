module FormLimitations
  TYPE_LIMITS = [ {type: :name, limit: 25},
                  {type: :email, limit: 40},
                  {type: :address, limit: 50},
                  {type: :notes, limit: 500},
                  {type: :zipcode, limit: 5},
                  {type: :default, limit: 25}]
end