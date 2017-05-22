module TutorialsHelper
  def tutorial_icon(tutorial)
    case tutorial_id(tutorial)
      when 'home'
        '#icon-house-large'
      when 'add-primary-contact', 'add-tax-accountant'
        '#icon-woman'
      when 'insurance', 'life-disability'
        '#icon-document-shield'
      when 'vehicle'
        '#icon-car-large'
      when 'add-financial-advisor'
        '#icon-business-man-2'
      when 'property-casualty'
        '#icon-umbrella-1'
      when 'insurance-broker'
        '#icon-business-man-1'
      else
        '#icon-activity-monitor-1'
    end
  end
  
  def tutorial_id(tutorial)
    tutorial.try(:short_name) || tutorial[:name].downcase.split(' ').join('-')
  end
  
  def check_tutorial_params(property_param)
    if params[:tutorial_name] && property_param.empty?
      if params[:next_tutorial] == 'confirmation_page'
        redirect_to tutorials_confirmation_path and return true
      else
        tuto_index = session[:tutorial_index]
        next_page = session[:tutorial_paths][tuto_index][:current_page]
        redirect_to tutorial_page_path(params[:next_tutorial], next_page) and return true
      end
    end
  end
  
  def tutorial_redirection(format, json_object, success_message)
    tuto_index = session[:tutorial_index]
    next_tuto = session[:tutorial_paths][tuto_index]
    next_page = session[:tutorial_paths][tuto_index][:current_page]
    path = if next_tuto[:tuto_name] == 'confirmation_page'
      tutorials_confirmation_path
    else
       tutorial_page_path(next_tuto[:tuto_name], next_page)
    end
    format.json { render json: json_object }
    format.html { redirect_to path, flash: { success: success_message } }
  end
  
  def tutorial_error_handle(message, tutorial, page)
    if params[:tutorial_name]
      flash[:alert] = message
      redirect_to tutorial_page_path(tutorial, page) and return true
    end
  end
end
