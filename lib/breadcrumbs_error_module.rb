module BreadcrumbsErrorModule
  def financial_error_breadcrumb_update
    breadcrumbs.clear
    set_provider if @path[:action].eql? :edit
    add_breadcrumb "Financial Information", :financial_information_path if general_view?
    add_breadcrumb "Financial Information", shared_view_financial_information_path(shared_user_id: @shared_user.id) if shared_view?
    set_add_crumbs && return if @path[:action].eql? :new
    if @path[:action].eql? :edit
      set_details_crumbs
      set_edit_crumbs
    end
  end

  module_function :financial_error_breadcrumb_update
end
