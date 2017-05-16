class PagesController < HighVoltage::PagesController
  before_action :set_cache_headers
  layout 'without_sidebar_layout'

  def confirmation; end

  def show
    # Params = {"tutorial_id"=>"insurance", "page_id"=>"1"}
    @page_number   = params[:page_id]
    @tutorial_name = params[:tutorial_id]
    @tutorial      = Tutorial.find_by(slug: @tutorial_name.split("-").join(" ").titleize)

    # For Add Primary Contact view
    @primary_contacts = Contact.for_user(current_user).where(relationship: Contact::CONTACT_TYPES['Family & Beneficiaries'], contact_type: 'Family & Beneficiaries')
    @contact = Contact.new(user: current_user)
    @show_footer = false
    tuto_index = session[:tutorial_index] + 1

    if session[:tutorial_paths][tuto_index]
     @next_tutorial_name = session[:tutorial_paths][tuto_index][:tuto_name]
    else
      redirect_to new_tutorial_path and return
    end

    # @next_tutorial_name = session[:tutorial_paths][tuto_index][:tuto_name]
    @next_tutorial = Tutorial.find_by(slug: @next_tutorial_name.titleize)
    @next_page = session[:tutorial_paths][tuto_index][:current_page]
    @page_name     = "page_#{@page_number}"

    session[:tutorial_index] = session[:tutorial_index] + 1
  end

  private
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
