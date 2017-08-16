module SharedUserExpired
  def shared_user_expired
    @expired_user = User.find_by(id: params[:shared_user_id])
  end
end
