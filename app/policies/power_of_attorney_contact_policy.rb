class PowerOfAttorneyContactPolicy < CategorySharePolicy

  def destroy_power_of_attorney_contact?
    user_owned?
  end

  def new_wills_poa?
    create?
  end

end
