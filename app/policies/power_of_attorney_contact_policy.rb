class PowerOfAttorneyContactPolicy < CategorySharePolicy

  def destroy_power_of_attorney_contact?
    user_owned?
  end
end
