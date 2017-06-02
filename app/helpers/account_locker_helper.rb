module AccountLockerHelper
  def failed_attempts_limit_reached?
    failed_attempts_count = current_user.failed_attempts
    attempts_remaining = (Session::FAILED_ATTEMPTS_LIMIT - 1) - failed_attempts_count
    if attempts_remaining <= 0
      return true
    elsif
      current_user.increment!(:failed_attempts)
    end
    false
  end
  
  def lock_account
    current_user.lock_access!
    reset_session
    true
  end
end
