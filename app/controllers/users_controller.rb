class UsersController < AuthenticatedController
  before_action :is_admin?
  before_action :set_user, only: [:destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.transaction do
      Contact.where(user: @user).each do |contact|
        Vendor.where(contact: contact).destroy_all
        contact.destroy
      end
      @user.destroy
    end

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {})
    end
end
