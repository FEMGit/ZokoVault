class InterestedUsersController < ApplicationController
  before_action :check_privileges, only: [:index, :show, :edit, :update, :destroy]
  before_action :set_interested_user, only: [:show, :edit, :update, :destroy]

  # GET /interested_users
  # GET /interested_users.json
  def index
    @interested_users = InterestedUser.all
  end

  def mailing_list_confirm
  end

  # GET /interested_users/1
  # GET /interested_users/1.json
  def show
  end

  # GET /interested_users/1/edit
  def edit
  end

  # POST /interested_users
  # POST /interested_users.json
  def create
    @interested_user = InterestedUser.new(interested_user_params)

    respond_to do |format|
      if @interested_user.save
        format.html { redirect_to mailing_list_confirm_path }
      else
        format.html { render 'pages/mailing-list' }
        format.json { render json: @interested_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interested_users/1
  # DELETE /interested_users/1.json
  def destroy
    @interested_user.destroy
    respond_to do |format|
      format.html { redirect_to interested_users_url, notice: 'User informtaion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_interested_user
    @interested_user = InterestedUser.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def interested_user_params
    params.require(:interested_user).permit!
  end

  def check_privileges
    if user_exists_and_admin?
      true
    else
      redirect_to root_path
    end
  end

  def user_exists_and_admin?
    current_user && current_user.admin?
  end
end
