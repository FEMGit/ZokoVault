class UsersController < AuthenticatedController
  include BackPathHelper
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
      PowerOfAttorneyContact.where(user: @user).each { |pofc| pofc.destroy }
      CardDocument.where(user_id: @user.id).each { |card_doc| card_doc.destroy }
      @user.destroy
    end

    recognized_path = Rails.application.routes.recognize_path(back_path)
    
    respond_to do |format|
      return_path = recognized_path.present? ? {:controller => recognized_path[:controller], :action => :index } : users_url
      format.html { redirect_to return_path, notice: 'User was successfully destroyed.' }
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
