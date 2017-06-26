module AccountLockerHelper
  def mfa_failed_attempts_limit_reached?
    attempts_remaining = (Session::FAILED_ATTEMPTS_LIMIT - 1) - current_user.mfa_failed_attempts
    if attempts_remaining <= 0
      return true
    elsif
      current_user.increment!(:mfa_failed_attempts)
    end
    false
  end
  
  def lock_account
    current_user.lock_access!
    reset_session
    true
  end
end
