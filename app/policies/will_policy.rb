class WillPolicy < CategorySharePolicy

  def update_wills?
    update?
  end

  def new_wills_poa?
    create?
  end

end
