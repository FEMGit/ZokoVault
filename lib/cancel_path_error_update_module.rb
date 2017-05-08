module CancelPathErrorUpdateModule
  def self.included(base)
    base.before_filter :cancel_path_update
  end

  def cancel_path_update
    @cancel_button_path = params[:cancel_button_path]
  end
end
