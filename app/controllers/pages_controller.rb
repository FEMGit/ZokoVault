class PagesController < HighVoltage::PagesController
  layout 'blank_layout'

  def confirmation; end

  def show
    # Params = {"tutorial_id"=>"insurance", "page_id"=>"1"}
    @page_number   = params[:page_id]
    @page_name     = "page_#{@page_number}"
    @tutorial_name = params[:tutorial_id]
    @tutorial      = Tutorial.find_by(name: @tutorial_name.split("-").join(" ").humanize)

    # For Add Primary Contact view
    @primary_contacts = Contact.for_user(current_user).where(relationship: Contact::CONTACT_TYPES['Family & Beneficiaries'], contact_type: 'Family & Beneficiaries')
    @contact = Contact.new(user: current_user)
    @show_footer = false

    @next_page = @page_number.to_i + 1
    if @tutorial_name == 'home'
      session[:tutorial_index] = session[:tutorials_list].find_index(@tutorial.id.to_s).to_i + 1
    elsif @tutorial_name == 'insurance'
      session[:tutorial_index] = session[:tutorials_list].find_index(@tutorial.id.to_s).to_i + 1
    else
      session[:tutorial_index] = session[:tutorials_list].find_index(@tutorial.id.to_s).to_i + 1
    end
    @next_tutorial = 'confirmation-page'
    @next_tutorial = Tutorial.find(session[:tutorials_list][session[:tutorial_index]]) if session[:tutorials_list][session[:tutorial_index]].present?
  end
end
