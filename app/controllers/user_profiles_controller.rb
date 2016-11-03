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
    @user_profile = UserProfile.new
    @user_profile.employers.first_or_initialize
  end

  # GET /user_profiles/1/edit
  def edit
    @user_profile.employers.first_or_initialize
  end

  # POST /user_profiles
  # POST /user_profiles.json
  def create
    @user_profile = UserProfile.new(user_profile_params)
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
  end

  def set_contacts
    @contacts = Contact.for_user(current_user)
  end

  def user_profile_params
    params.require(:user_profile).permit!
  end
end