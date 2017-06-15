module TutorialsHelper
  def tutorial_unfinished?
    return false unless current_user
    TutorialSelection.for_user(current_user).present?
  end
  
  def tutorial_subtutorial_icon(tutorial)
    tutorial_id = tutorial_id(tutorial.try(:name))
    if tutorial.is_a? Subtutorial
      subtutorial_icon(tutorial_id)
    elsif tutorial.is_a? Tutorial
      tutorial_icon(tutorial_id)
    else
      '#icon-activity-monitor-1'
    end
  end
  
  def tutorial_icon(tutorial_id)
    case tutorial_id
      when 'i-have-a-will'
        '#icon-ribbon'
      when 'i-have-insurance'
        '#icon-document-shield'
      when 'i-have-tax-documents'
        '#icon-document-3'
      when 'i-have-a-trust'
        '#icon-shield-check'
      when 'i-have-financial-information'
        '#icon-piggy-bank'
      when 'i-own-a-vehicle'
        '#icon-car-large'
      when 'i-have-a-home'
        '#icon-house-large'
      when 'i-have-a-family'
        '#icon-woman'
      else
        '#icon-activity-monitor-1'
    end
  end
  
  def subtutorial_icon(tutorial_id)
    case tutorial_id
      # Will
      when 'i-have-a-will',
           'my-spouse-has-a-will'
        '#icon-ribbon'
      when 'i-have-an-estate-planning-attorney'
        '#icon-woman'
  
      # Taxes
      when 'i-have-tax-documents'
        '#icon-document-3'
      when 'i-want-to-store-my-digital-tax-files'
        '#icon-document-3'
      when'i-have-a-tax-accountant'
        '#icon-calculator'
    
      # Trusts
      when 'i-have-a-trust'
        '#icon-trust'
      when 'i-have-a-family-entity'
        '#icon-family'
      when 'i-have-a-trust-or-entity-attorney'
        '#icon-business-man-2'
     
      # Financial Information
      when 'i-have-a-financial-advisor'
        '#icon-business-man-2'
      when 'i-have-a-checking-account'
        '#icon-check'
      when 'i-have-investments'
        '#icon-graph-3'
      when 'i-have-mortgage'
        '#icon-house-large'
      when 'i-have-valuable-property'
        '#icon-gold'
      when 'i-have-credit-cards'
        '#icon-credit-card-1'
      when 'i-have-jewelry'
        '#icon-ring'
      when 'i-have-alternative-investments'
        '#icon-document-financial'
      when 'i-own-a-business'
        '#icon-building'
      
      # Insurance
      when 'i-have-life-or-disability-insurance'
        '#icon-document-shield'
      when 'i-have-property-insurance'
        '#icon-umbrella-1'
      when 'i-have-health-insurance'
        '#icon-shield-health'
      when 'i-have-an-insurance-broker'
        '#icon-business-man-2'
      else
        '#icon-activity-monitor-1'
    end
  end
  
  def tutorial_id(tutorial_name)
    return "" unless tutorial_name.present?
    tutorial_name.downcase.split('.').first.split(' ').join('-')
  end
  
  def tutorial_name(tutorial_id)
    return "" unless tutorial_id.present?
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
    Contact.for_user(current_user).any? { |c| c.relationship == 'Spouse / Domestic Partner' }
  end

  # Tutorial selection
  def clean_tutorial_progress
    TutorialSelection.where(user_id: current_user.try(:id)).destroy_all
  end

  def save_tutorial_progress
    tutorial_selection = TutorialSelection.find_or_create_by(user_id: current_user.try(:id))
    tutorial_selection.tutorial_paths = session[:tutorial_paths].to_json
    tutorial_selection.last_tutorial_index = session[:tutorial_index]
    tutorial_selection.save
  end

  def redirect_to_last_tutorial
    if tutorial_selection_exists?
      tutorial_selection = TutorialSelection.find_by(user: current_user)
      tutorial_paths = tutorial_selection.tutorial_paths.map { |x| x.symbolize_keys }
      tutorial_index = tutorial_selection.last_tutorial_index
      if session[:tutorial_paths].blank?
        return if tutorial_paths == session[:tutorial_paths]
        session[:tutorial_paths] = tutorial_paths
        session[:tutorial_index] = tutorial_selection.last_tutorial_index
        return unless current_tutorial_path
        redirect_to current_tutorial_path and return if current_tutorial_path != request.fullpath
      else
        session[:tutorial_index] -= 1 if (request.fullpath == onboarding_back_path &&
                                        session[:tutorial_index] > 0 &&
                                        tutorial_paths.count > 2)
        return unless current_tutorial_path
        redirect_to current_tutorial_path and return if current_tutorial_path != request.fullpath
      end
    end
  end

  def current_tutorial_path
    return if session[:tutorial_paths].blank?
    current_tutorial = session[:tutorial_paths][session[:tutorial_index]]
    return if current_tutorial.blank?
    if current_tutorial[:tuto_name] == 'tutorial_new'
      return if request.fullpath.eql? new_tutorial_path
      new_tutorial_path
    elsif current_tutorial[:tuto_name] == 'lets_get_started'
      return if request.fullpath.eql? new_tutorial_path
      tutorials_lets_get_started_path
    else
      tutorial_page_path(current_tutorial[:tuto_name], current_tutorial[:current_page])
    end
  end

  def tutorial_selection_exists?
    tutorial_selection = TutorialSelection.find_by(user: current_user)
    tutorial_selection.present? && tutorial_selection.tutorial_paths.present?
  end
end
