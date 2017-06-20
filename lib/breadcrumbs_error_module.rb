module BreadcrumbsErrorModule
  def financial_error_breadcrumb_update
    breadcrumbs.clear
    set_provider if @path[:action].eql? :edit
    add_breadcrumb "Financial Information", :financial_information_path if general_view?
    add_breadcrumb "Financial Information", shared_view_financial_information_path(shared_user_id: @shared_user.id) if shared_view?
    set_add_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
  end

  def wills_error_breadcrumb_update
    breadcrumbs.clear
    set_will if @path[:action].eql? :edit
    add_breadcrumb "Wills & Powers of Attorney", :wills_powers_of_attorney_path if general_view?
    add_breadcrumb "Wills & Powers of Attorney", shared_view_wills_powers_of_attorney_path(shared_user_id: @shared_user.id) if shared_view?
    set_new_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
  end
  
  def poa_error_breadcrumb_update
    breadcrumbs.clear
    add_breadcrumb "Wills & Powers of Attorney", :wills_powers_of_attorney_path if general_view?
    add_breadcrumb "Wills & Powers of Attorney", shared_view_wills_powers_of_attorney_path(shared_user_id: @shared_user.id) if shared_view?
    set_new_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
  end

  def entities_breadcrumb_update
    breadcrumbs.clear
    set_entity if @path[:action].eql? :edit
    add_breadcrumb "Trusts & Entities", :trusts_entities_path if general_view?
    add_breadcrumb "Trusts & Entities", shared_view_trusts_entities_path(shared_user_id: @shared_user.id) if shared_view?
    set_new_crumbs && return if @path[:action].eql? :new
    edit_crumbs_set
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

  private

  def edit_crumbs_set
    if @path[:action].eql? :edit
      set_details_crumbs
      set_edit_crumbs
    end
  end

  module_function :wills_error_breadcrumb_update, :entities_breadcrumb_update,
                  :insurance_breadcrumb_update, :financial_error_breadcrumb_update
end
