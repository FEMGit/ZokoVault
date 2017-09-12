class ToDoPopupController < AuthenticatedController
  def do_not_show_popup
    redirect_to root_path and return unless do_not_show_modal_popup_path
    to_do_popup_cancel = ToDoPopupCancel.find_or_initialize_by(user: current_user)
    redirect_to root_path and return unless cancelled_category_name = 
      ToDoPopupModal.popup_name_by_route(path: do_not_show_modal_popup_path)
    to_do_popup_cancel.update(cancelled_popups: (to_do_popup_cancel.cancelled_popups + [cancelled_category_name]).uniq)
    render nothing: true
  end
  
  private
  
  def do_not_show_modal_popup_path
    return nil unless params[:to_do_modal_popup_path]
    params.require(:to_do_modal_popup_path)
  end
end
