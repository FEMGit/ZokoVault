class UserProfilesController < AuthenticatedController
  before_action :set_user_profile, only: [:index, :edit, :update]
  before_action :set_contacts, only: [:edit, :update]
  before_action :save_user_profile_info, only: [:update]
  include SanitizeModule

  skip_before_action :redirect_if_free_user

  # Breadcrumbs navigation
  add_breadcrumb "My Profile", :my_profile_path
  add_breadcrumb "Edit My Profile", :edit_user_profile_path, only: [:edit]
  include BreadcrumbsCacheModule
  include BreadcrumbsErrorModule
  include UserTrafficModule

  def page_name
    case action_name
      when 'edit'
        return "Edit My Profile"
      when 'index'
        return "My Profile"
    end
  end

  def index
    authorize @user_profile
    @category = "My Profile"
    @my_profile_documents = Document.for_user(current_user).where(category: @category)
    session[:ret_url] = my_profile_path
  end

  def edit
    authorize @user_profile
    @user_profile.employers.first_or_initialize
  end

  def update
    authorize @user_profile
    params[:user_profile][:date_of_birth] = date_format
    respond_to do |format|
      if @user_profile.update(user_profile_params)
        format.html { redirect_to my_profile_path, flash: { success: 'User profile was successfully updated.' } }
        format.json { render :show, status: :ok, location: @user_profile }
      else
        my_profile_error_breadcrumb_update
        format.html { render :edit }
        format.json { render json: @user_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  
  def save_user_profile_info
    @user_profile_stored = @user_profile.dup
  end
  
  def set_user_profile
    @user_profile = current_user.user_profile
    authorize @user_profile
  end

  def set_contacts
    @contacts = Contact.for_user(current_user)
    @contacts_shareable = @contacts.reject { |c| c.emailaddress == current_user.email }
  end

  def user_profile_params
    params.require(:user_profile).permit(:user_id, :first_name, :middle_name,
                                         :last_name, :phone_number_mobile, :phone_number,
                                         :date_of_birth, :photourl, :street_address_1, :city, :state, :zip, :notes,
                                         employers_attributes: [:name, :web_address, :street_address_1,
                                                                :city, :state, :zip, :phone_number_office,
                                                                :phone_number_fax, :id])
  end

  def date_format
    return user_profile_params[:date_of_birth] unless user_profile_params[:date_of_birth].include?('/')
    date_params = user_profile_params[:date_of_birth].split('/')
    year = date_params[2]
    month = date_params[0]
    day = date_params[1]
    "#{year}-#{month}-#{day}"
  end
end
