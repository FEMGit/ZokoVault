class WillPolicy < CategorySharePolicy

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def update_wills?
    update?
  end

  def new_wills_poa?
    create?
  end

end
