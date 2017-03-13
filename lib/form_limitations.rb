module FormLimitations
  TYPE_LIMITS = [ {type: :notes, limit: 1000},
                  {type: :web, limit: 100},
                  {type: :web_prefix, limit: 10},
                  {type: :wtl_name, limit: 100},
                  {type: :zipcode, limit: 5},
                  {type: :default, limit: 50},
                  {type: :year, limit: 4}]
end
