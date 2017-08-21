module BreadcrumbsErrorModule
  def financial_error_breadcrumb_update
    breadcrumbs.clear
    add_breadcrumb "Financial Information", :financial_information_path if general_view?
    add_breadcrumb "Financial Information", shared_view_financial_information_path(shared_user_id: @shared_user.id) if shared_view?
    set_add_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
  end
  
  def error_path_generate(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names_full = ReturnPathService.shared_category_names(@path)
    yield
  end

  def wills_error_breadcrumb_update
    wills_poa_error_breadcrumbs_update { set_will if @path[:action].eql? :edit }
  end
  
  def poa_error_breadcrumb_update
    wills_poa_error_breadcrumbs_update
  end

  def entities_breadcrumb_update
    trusts_entities_breadcrumb_update { set_entity if @path[:action].eql? :edit }
  end
  
  def trusts_breadcrumb_update
    trusts_entities_breadcrumb_update { set_trust if @path[:action].eql? :edit }
  end

  def insurance_breadcrumb_update(type)
    breadcrumbs.clear
    if @path[:action].eql? :edit
      case type
      when :life
        set_life
      when :health
        set_health
      when :property
        set_property_and_casualty
      end
    end
    add_breadcrumb "Insurance", :insurance_path if general_view?
    add_breadcrumb "Insurance", shared_view_insurance_path(shared_user_id: @shared_user.id) if shared_view?
    set_new_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
  end
  
  def corporate_account_error_breadcrumb_update
    breadcrumbs.clear
    if @path[:action].eql? :edit
      set_corporate_contact_by_user_profile 
    end
    add_breadcrumb "Corporate Account", :corporate_accounts_path if ([:new, :edit, :index].include? @path[:action])
    set_new_crumbs && return if @path[:action].eql? :new
    if @path[:action].eql? :edit_account_settings
      set_account_settings_crumbs
      set_edit_corporate_details_crumbs
      return
    end
    edit_crumbs_set
  end
  
  def corporate_employee_error_breadcrumb_update
    breadcrumbs.clear
    set_corporate_contact_by_user_profile if @path[:action].eql? :edit
    add_breadcrumb "Employee Accounts", :corporate_employees_path if ([:new, :edit, :index].include? @path[:action])
    set_new_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
  end
  
  def my_profile_error_breadcrumb_update
    breadcrumbs.clear
    add_breadcrumb "My Profile", :my_profile_path
    add_breadcrumb "Edit My Profile", :edit_user_profile_path
  end

  private
  
  def wills_poa_error_breadcrumbs_update
    breadcrumbs.clear
    yield
    add_breadcrumb "Wills & Powers of Attorney", :wills_powers_of_attorney_path if general_view?
    add_breadcrumb "Wills & Powers of Attorney", shared_view_wills_powers_of_attorney_path(shared_user_id: @shared_user.id) if shared_view?
    set_new_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
  end
  
  def trusts_entities_breadcrumb_update
    breadcrumbs.clear
    yield
    add_breadcrumb "Trusts & Entities", :trusts_entities_path if general_view?
    add_breadcrumb "Trusts & Entities", shared_view_trusts_entities_path(shared_user_id: @shared_user.id) if shared_view?
    set_new_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
  end

  def edit_crumbs_set
    if @path[:action].eql? :edit
      set_details_crumbs
      set_edit_crumbs
    end
  end

  module_function :wills_error_breadcrumb_update, :entities_breadcrumb_update,
                  :insurance_breadcrumb_update, :financial_error_breadcrumb_update,
                  :corporate_account_error_breadcrumb_update
end
