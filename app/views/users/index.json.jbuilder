json.array!(@users) do |user|
  json.extract! user, :id, :first_name, :last_name, :email, :password, :date_of_birth, :admin, :password_confirmation
  json.url user_url(user, format: :json)
end
