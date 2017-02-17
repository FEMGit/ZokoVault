module FormLimitations
  TYPE_LIMITS = [ {type: :notes, limit: 1000},
                  {type: :web, limit: 40},
                  {type: :zipcode, limit: 5},
                  {type: :default, limit: 50},
                  {type: :year, limit: 4}]
end
