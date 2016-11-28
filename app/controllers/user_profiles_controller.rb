class UserProfilesController < AuthenticatedController
  before_action :set_user_profile, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]

  # GET /user_profiles
  # GET /user_profiles.json
  def index
    @user_profiles = UserProfile.all
  end

  # GET /user_profiles/1
  # GET /user_profiles/1.json
  def show
    @category = "My Profile"
    @my_profile_documents = Document.for_user(current_user).where(category: @category)
    session[:ret_url] = user_profile_path
  end

  # GET /user_profiles/new
  def new
    @user_profile = UserProfile.new(user: current_user)
    @user_profile.employers.first_or_initialize
    authorize @user_profile
  end

  # GET /user_profiles/1/edit
  def edit
    @user_profile.employers.first_or_initialize
  end

  # POST /user_profiles
  # POST /user_profiles.json
  def create
    @user_profile = UserProfile.new(user_profile_params)
    authorize @user_profile
    respond_to do |format|
      if @user_profile.save
        format.html { redirect_to user_profile_path, notice: 'User profile was successfully created.' }
        format.json { render :show, status: :created, location: @user_profile }
      else
        format.html { render :new }
        format.json { render json: @user_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_profiles/1
  # PATCH/PUT /user_profiles/1.json
  def update
    user_profile_params[:date_of_birth] = date_format
    respond_to do |format|
      if @user_profile.update(user_profile_params)
        format.html { redirect_to user_profile_path, notice: 'User profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_profile }
      else
        format.html { render :edit }
        format.json { render json: @user_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_profiles/1
  # DELETE /user_profiles/1.json
  def destroy
    @user_profile.destroy
    respond_to do |format|
      format.html { redirect_to user_profile_url, notice: 'User profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

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
                                         :last_name, :email, :phone_number_mobile, :phone_number,
                                         :date_of_birth, :street_address_1, :city, :state, :zip, :notes,
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
