json.array!(@interested_users) do |interested_user|
  json.extract! interested_user, :id
  json.url interested_user_url(interested_user, format: :json)
end
