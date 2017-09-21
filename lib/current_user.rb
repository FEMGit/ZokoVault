module CurrentUser
  def current_user
    Thread.current[:current_user]
  end
end
