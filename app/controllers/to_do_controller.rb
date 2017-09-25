class ToDoController < AuthenticatedController
  def do_not_show
    respond_to do |format|
      unless do_not_show_modal_popup_path
        format.html { redirect_to root_path }
        format.json { render json: { error: "Error removing to do item.", status: 500 }, status: 500 }
        return
      end
      to_do_cancel = ToDoCancel.find_or_initialize_by(user: current_user)
      unless cancelled_category_name = 
        ToDoItem.category_name_by_modal_route(path: do_not_show_modal_popup_path)
        format.html { redirect_to root_path }
        format.json { render json: { error: "Error removing to do item.", status: 500 }, status: 500 }
        return 
      end
      to_do_cancel.update(cancelled_categories: (to_do_cancel.cancelled_categories + [cancelled_category_name]).uniq)
      format.html { render nothing: true }
      format.json { render json: { status: 200 }, status: 200 }
    end
  end
  
  private
  
  def do_not_show_modal_popup_path
    return nil unless params[:to_do_modal_popup_path]
    params.require(:to_do_modal_popup_path)
  end
end
