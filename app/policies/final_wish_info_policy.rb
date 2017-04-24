class FinalWishInfoPolicy < BasicPolicy

  def scope
    Pundit.policy_scope!(user, record.class)
  end

end
