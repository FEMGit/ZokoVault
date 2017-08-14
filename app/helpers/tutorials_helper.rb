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
      when 'my-will(s)'
        '#icon-ribbon'
      when 'my-insurance'
        '#icon-document-shield'
      when 'my-taxes'
        '#icon-document-3'
      when 'my-trust(s)'
        '#icon-shield-check'
      when 'my-financial-information'
        '#icon-piggy-bank'
      when 'my-vehicle(s)'
        '#icon-car-large'
      when 'my-home'
        '#icon-house-large'
      when 'my-family'
        '#icon-woman'
      else
        '#icon-activity-monitor-1'
    end
  end
  
  def subtutorial_icon(tutorial_id)
    case tutorial_id
      # Will
      when 'my-will',
           "my-spouse's-will"
        '#icon-ribbon'
      when 'my-estate-planning-attorney'
        '#icon-woman'
  
      # Taxes
      when 'i-have-tax-documents'
        '#icon-document-3'
      when 'my-digital-tax-files'
        '#icon-document-3'
      when'my-tax-accountant'
        '#icon-calculator'
    
      # Trusts
      when 'my-trust'
        '#icon-trust'
      when 'my-family-entity'
        '#icon-family'
      when 'my-attorney'
        '#icon-business-man-2'
     
      # Financial Information
      when 'my-financial-advisor'
        '#icon-business-man-2'
      when 'my-bank-accounts'
        '#icon-check'
      when 'my-other-investments'
        '#icon-graph-3'
      when 'my-valuable-property'
        '#icon-gold'
      when 'my-alternative-investments'
        '#icon-document-financial'
      when 'my-business'
        '#icon-building'
      
      # Insurance
      when 'my-life-or-disability-insurance'
        '#icon-document-shield'
      when 'my-property-insurance'
        '#icon-umbrella-1'
      when 'my-health-insurance'
        '#icon-shield-health'
      when 'my-insurance-broker(s)'
        '#icon-business-man-2'
      when 'upload-my-policies'
        '#icon-document-3'
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
    (tutorial_id.split("-").join(" ")).downcase
  end
  
  def select_tag_values(resource)
    return resource.try(:accounts).map(&:account_type) if resource.try(:provider_type) == "Account"
    return resource.try(:alternatives).map(&:alternative_type) if resource.try(:provider_type) == "Alternative"
    resource.try(:investment_type) || ''
  end
  
  def check_tutorial_params(property_param)
    if params[:tutorial_name] && property_param.empty?
      if params[:next_tutorial_path].present? &&
         (Rails.application.routes.recognize_path(params[:next_tutorial_path]) rescue nil).present?
        redirect_to params[:next_tutorial_path] and return true
      elsif params[:next_tutorial] == 'confirmation_page'
        redirect_to tutorials_confirmation_path and return true
      else
        tuto_index = session[:tutorial_index]
        next_page = session[:tutorial_paths][tuto_index][:current_page]
        redirect_to tutorial_page_path(params[:next_tutorial], next_page) and return true
      end
    end
  end
  
  def tutorial_redirection(format, json_object)
    tuto_index = session[:tutorial_index]
    next_tuto = session[:tutorial_paths][tuto_index]
    if params[:next_tutorial_path].present? &&
       (Rails.application.routes.recognize_path(params[:next_tutorial_path]) rescue nil).present?
      path = params[:next_tutorial_path]
    elsif session[:tutorial_paths].present? &&
         session[:tutorial_paths][tuto_index].present?
      next_page = session[:tutorial_paths][tuto_index][:current_page]
      path = if next_tuto[:tuto_name] == 'confirmation_page'
        tutorials_confirmation_path
      elsif next_tuto[:tuto_name] == 'tutorial_new'
        new_tutorial_path
      else
        tutorial_page_path(next_tuto[:tuto_name], next_page)
      end
    else
      path = new_tutorial_path
    end
    format.json { render json: json_object }
    format.html { redirect_to path }
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
    return true unless tutorial.name.eql? "My spouse's will."
    Contact.for_user(current_user).any? { |c| c.relationship == 'Spouse / Domestic Partner' }
  end

  # Tutorial selection
  def clean_tutorial_progress
    TutorialSelection.where(user_id: current_user.try(:id)).destroy_all
  end

  def save_tutorial_progress
    return if params[:next_tutorial_path].present? || params[:return_path].present?
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
      if session[:tutorial_paths].blank? || session[:category_tutorial_in_progress].eql?(true)
        session[:category_tutorial_in_progress] = false
        return if tutorial_paths == session[:tutorial_paths]
        session[:tutorial_paths] = tutorial_paths
        session[:tutorial_index] = tutorial_selection.last_tutorial_index
        return unless current_tutorial_path
        redirect_to current_tutorial_path and return true if current_tutorial_path != request.fullpath
      else
        session[:tutorial_index] -= 1 if (request.fullpath == onboarding_back_path &&
                                        session[:tutorial_index] > 0 &&
                                        tutorial_paths.count > 2)
        return unless current_tutorial_path
        redirect_to current_tutorial_path and return true if current_tutorial_path != request.fullpath
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
    return false unless (tutorial_selection && tutorial_selection.tutorial_paths)
    current_tutorial = tutorial_selection.tutorial_paths[tutorial_selection.last_tutorial_index]
    return false unless current_tutorial
    if !current_tutorial["tuto_name"].eql? 'vault_co_owners'
      return tutorial_selection.present? && tutorial_selection.tutorial_paths.present?
    else
      return (request.fullpath == onboarding_back_path)
    end
  end

  # Tutorial Path Generation
  def tutorial_path_hash(tuto, current_page, tutorial)
    {
      tuto_id: tuto,
      current_page: current_page,
      tuto_name: tutorial_id(tutorial.name)
    }
  end

  # Tutorial Buttons
  def skip_button_path
    if @next_tutorial_name == 'confirmation_page'
      tutorials_confirmation_path
    else
      tutorial_page_path(@next_tutorial_name, @next_page)
    end
  end

  # Tutorial Update
  def update_all_params
    return nil unless params[:update_fields]
    params.require(:update_fields)
  end

  def multiple_types_create(tutorial_multiple_types_params, key, resource_owner)
    return false unless tutorial_multiple_types_params.present?
    types = tutorial_multiple_types_params[:types].reject(&:blank?)
    @financial_provider = FinancialProvider.new(provider_params.merge(user_id: resource_owner.id, provider_type: provider_type))
    authorize @financial_provider
    types.collect! { |x| [key => x] }.flatten!
    types.each do |type|
      if key.eql? :account_type
        FinancialInformationService.fill_accounts({ key => type }, @financial_provider, resource_owner.id)
      elsif key.eql? :alternative_type
        FinancialInformationService.fill_alternatives({ key => type }, @financial_provider, resource_owner.id)
      end
    end
    respond_to do |format|
      if @financial_provider.save
        if params[:tutorial_name]
          tutorial_redirection(format, @financial_provider.as_json)
        end
      else
        tutorial_error_handle("Fill in Provider Name field to continue") && return
      end
    end
    true
  end

  def tutorial_multiple_types_params
    last_tutorial_multiple_params = params.select { |k, _v| k.include? 'tutorial_multiple_types' }.to_a.last
    return nil if last_tutorial_multiple_params.blank?
    params.require(last_tutorial_multiple_params[0]).permit(types: [])
  end

  # Balance Sheet Tutorial Check
  def set_balance_sheet_information(tutorial_id)
    if tutorial_id.eql? 'balance-sheet'
      if financial_information_any?
        set_financial_information_resources
      else
        tuto_index = session[:tutorial_index] + 1
        if session[:category_tutorial_in_progress] == true
          session[:tutorial_index] += 1
          redirect_to financial_information_path(tutorial_in_progress: true) and return if session[:tutorial_paths][tuto_index].blank?
        end
        @next_tutorial_name = session[:tutorial_paths][tuto_index][:tuto_name]
        @next_tutorial = Tutorial.where('name ILIKE ?', tutorial_name(@next_tutorial_name)).first
        @next_page = session[:tutorial_paths][tuto_index][:current_page]
        @page_name     = "page_#{@page_number}"

        session[:tutorial_index] = session[:tutorial_index] + 1
        if session[:category_tutorial_in_progress] == true
          redirect_to financial_information_path(tutorial_in_progress: true) and return
        else
          redirect_to tutorial_page_path(@next_tutorial, @next_page) and return
        end
      end
    end
  end

  def set_taxes_configuration(tutorial_id, tutorial_page)
    if tutorial_id.eql?('my-taxes')
      if tutorial_page == 2 && !@tax_accountants.any? { |pc| (pc.relationship.eql? 'Accountant') && (pc.contact_type.eql? 'Advisor') }
        if from_back_button?
          session[:tutorial_index] -= 1
        else
          session[:tutorial_index] += 1
        end
      end
    end
  end

  # Tutorial Category Integration
  def from_back_button?
    params[:back].present? && params[:back] == 'true'
  end

  def empty_category_tutorial_id(category)
    case category.name.downcase
      when Rails.application.config.x.WillsPoaCategory.downcase
        'my-will(s)'
      when Rails.application.config.x.TrustsEntitiesCategory.downcase
        'my-trust(s)'
      when Rails.application.config.x.InsuranceCategory.downcase
        'my-insurance'
      when Rails.application.config.x.FinancialInformationCategory.downcase
        'my-financial-information'
      when Rails.application.config.x.TaxCategory.downcase
        'my-taxes'
      else
        ''
    end
  end
  
  def empty_category_additional_tutorials(category)
    return [] unless category.present?
    case category.name.downcase
      when Rails.application.config.x.FinancialInformationCategory.downcase
        ['my vehicle(s)', 'my home']
      else
        []
    end
  end
  
  def empty_category_add_routes
    if @category.name.eql? Rails.application.config.x.FinancialInformationCategory
      session[:tutorial_paths] << { tuto_id: -1, current_page: 1, tuto_name: 'balance-sheet' }
    end
  end

  def tutorial_set_session(tutorial_id)
    tutorial = Tutorial.find_by(name: tutorial_name(tutorial_id).split.map(&:capitalize).join(' '))
    session[:tutorial_paths] = [{ tuto_id: 0, current_page: 0, tuto_name: 'tutorial_new' },
                                { tuto_id: tutorial.id.to_s, current_page: "subtutorials_choice", tuto_name: tutorial_id}]
    empty_category_add_routes
    session[:tutorial_index] = 1
  end

  def set_tutorial_in_progress(empty_category_status)
    if params[:tutorial_in_progress].present?
      @tutorial_in_progress = params[:tutorial_in_progress].eql?('true') ? true : false
    else
      @tutorial_in_progress = false
    end
    
    if empty_category_status && !@tutorial_in_progress.eql?(true)
      tutorial_set_session(empty_category_tutorial_id(@category))
      @tutorial_in_progress = true
    end
    
    if @tutorial_in_progress.eql? true
      set_tutorial_resources
      category_tutorial_step
    end
  end

  def tutorial_index_name
    tuto_index = session[:tutorial_index]

    if session[:tutorial_paths][tuto_index].present?
      tutorial_id = session[:tutorial_paths][tuto_index][:tuto_name]
      tutorial_page = session[:tutorial_paths][tuto_index][:current_page]
      set_taxes_configuration(tutorial_id, tutorial_page)
      tuto_index = session[:tutorial_index]
    end
    
    if session[:tutorial_paths][tuto_index].blank?
      tutorial_id = session[:tutorial_paths][session[:tutorial_paths].count - 2][:tuto_name]
      @tutorial_in_progress = false
      tutorial_set_session(tutorial_id)
      tuto_index = session[:tutorial_index]
    else
      @tutorial_id = session[:tutorial_paths][tuto_index][:tuto_name]
    end
    [tuto_index, tutorial_id]
  end

  def category_tutorial_step
    session[:category_tutorial_in_progress] = true
    session[:tutorial_paths].uniq!

    tuto_index, @tutorial_id = tutorial_index_name

    tuto_id = session[:tutorial_paths][tuto_index][:tuto_id]
    @tuto_page = session[:tutorial_paths][tuto_index][:current_page]
    @tutorial = Tutorial.where('name ILIKE ?', tutorial_name(@tutorial_id)).first
    set_balance_sheet_information(@tutorial_id)
    @subtutorials = @tutorial.try(:subtutorials).try(:sort_by, &:id)
                                                .try(:sort_by, &:position)

    empty_category_additional_tutorials(@category).each do |tutorial|
      tutorial = Tutorial.where('name ILIKE ?', tutorial).first
      next unless tutorial.present?
      @subtutorials << tutorial
    end
  end
end
