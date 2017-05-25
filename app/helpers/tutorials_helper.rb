module TutorialsHelper
  def tutorial_icon(tutorial)
    case tutorial_id(tutorial.try(:name))
      when 'i-have-a-home'
        '#icon-house-large'
      when 'i-have-a-family',
           'i-have-a-tax-accountant',
           'i-have-an-estate-planning-attorney'
        '#icon-woman'
      when 'i-have-insurance',
           'i-have-life-or-disability-insurance'
        '#icon-document-shield'
      when 'i-own-a-vehicle'
        '#icon-car-large'
      when 'i-have-a-financial-advisor'
        '#icon-business-man-2'
      when 'i-have-property-insurance'
        '#icon-umbrella-1'
      when 'i-have-an-insurance-broker'
        '#icon-business-man-1'
      else
        '#icon-activity-monitor-1'
    end
  end
  
  def tutorial_id(tutorial_name)
    return '' unless tutorial_name.present?
    tutorial_name.downcase.split('.').first.split(' ').join('-')
  end
  
  def tutorial_name(tutorial_id)
    (tutorial_id.split("-").join(" ") + '.').downcase
  end
  
  def select_tag_values(resource)
    resource.try(:alternatives).try(:first).try(:alternative_type) ||
      resource.try(:investment_type) || ''
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
  
  def tutorial_error_handle(message)
    if params[:tutorial_name]
      flash[:alert] = message
      session[:tutorial_index] -= 1
      current_tutorial = session[:tutorial_paths][session[:tutorial_index]]
      current_page = current_tutorial[:current_page]
      
      redirect_to tutorial_page_path(params[:tutorial_name], current_page) and return true
    end
  end

  # Will Subtutorials
  def will_subtutorial_show?(tutorial)
    return true unless tutorial.name.eql? 'My spouse has a will.'
    Contact.for_user(current_user).any? { |c| c.relationship == 'Spouse/Domestic Partner' }
  end
end
