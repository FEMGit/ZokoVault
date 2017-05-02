class TutorialsController < AuthenticatedController
  include UserTrafficModule
  include BackPathHelper
  skip_before_filter :complete_setup!, except: :show
  skip_before_filter :mfa_verify!
  before_action :set_new_contact, only: [:primary_contacts, :trusted_advisors]
  layout 'blank_layout', only: [:new, :create, :show,
                                :primary_contacts, :trusted_advisors,
                                :important_documents, :video]
  
  before_action :set_blank_layout_header_info, only: [:primary_contacts, :trusted_advisors,
                                                      :important_documents, :video]

  add_breadcrumb "Guided Tutorial - Important Documents", :tutorial_important_documents_path, only: [:important_documents]
  include BreadcrumbsCacheModule

  def page_name
    case action_name
      when 'primary_contacts'
        "Guided Tutorial - Primary Contacts"
      when 'trusted_advisors'
        "Guided Tutorial - Trusted Advisors"
      when 'important_documents'
        "Guided Tutorial - Important Documents"
      when 'Video'
        "Guided Tutorial - Video"
    end
  end

  def primary_contacts
    @primary_contacts = Contact.for_user(current_user).where(relationship: Contact::CONTACT_TYPES['Family & Beneficiaries'], contact_type: 'Family & Beneficiaries')
  end

  def trusted_advisors
    @trusted_advisors = Contact.for_user(current_user).where(relationship: Contact::CONTACT_TYPES['Advisor'], contact_type: 'Advisor')
  end

  def important_documents
    @documents = Document.for_user(current_user)
    session[:ret_url] = tutorial_important_documents_path
  end
  
  def video; end

  def new
    session[:tutorials_list] ||= {}
    @tutorial_array = Tutorial.first(3)
    @tutorial = Tutorial.new(name: session[:tutorials_list])
    @tutorial.current_step = session[:order_step]
  end

  def create
    session[:tutorials_list] = params["tutorial"] if params["tutorial"]
    session[:tutorial_paths] = tutorial_path_generator session[:tutorials_list]
    session[:tutorial_index] = 1
    tuto_index = session[:tutorial_index]
    tuto_id = session[:tutorial_paths][tuto_index][:tuto_id]
    @current_tutorial = Tutorial.find tuto_id
    current_tutorial_name = @current_tutorial.name.parameterize

    redirect_to tutorial_page_path(current_tutorial_name, '1')
  end

  def show
    @tutorial = Tutorial.find(params[:id])
  end

  def destroy
    previous_url = session[:previous_tuto].last[:my_previous_url]
    if previous_url.include? 'tutorials/new'
      redirect_to new_tutorial_path and return
    end

    if session[:previous_tuto].last[:reduce_tutorial_index]
      if previous_url.include? 'home'
        @tutorial = Tutorial.find_by(name: 'Home')
        session[:tutorial_index] = session[:tutorials_list].find_index(@tutorial.id.to_s).to_i + 1
      elsif previous_url.include? 'insurance'
        @tutorial = Tutorial.find_by(name: 'Insurance')
        session[:tutorial_index] = session[:tutorials_list].find_index(@tutorial.id.to_s).to_i + 1
      else
        @tutorial = Tutorial.find_by(name: 'Add Primary Contact')
        session[:tutorial_index] = session[:tutorials_list].find_index(@tutorial.id.to_s).to_i + 1
      end
    end

    session[:previous_tuto].pop
    redirect_to previous_url
  end

  private
  
  def set_blank_layout_header_info
    @header_information = true
  end

  def set_new_contact
    @contact = Contact.new(user: current_user)
  end

  def tutorial_path_generator(list)
    result = [{ tuto_id: 0, current_page: 0 }] # tutorial / new
    list.each do |tuto|
      tutorial = Tutorial.find(tuto)
      tutorial.number_of_pages.times do |p|
        result << {
          tuto_id: tuto,
          current_page: p + 1,
          tuto_name: tutorial.name.split(" ").join("-").downcase }
      end
    end
    result << { tuto_id: -1, current_page: -1, tuto_name: 'confirmation' } # tutorial / confirmation page
  end
end
