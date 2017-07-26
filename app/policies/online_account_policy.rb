class OnlineAccountPolicy < CategorySharePolicy
  def online_accounts?
    index?
  end
  
  def reveal_password?
    owned_or_shared?
  end
end
