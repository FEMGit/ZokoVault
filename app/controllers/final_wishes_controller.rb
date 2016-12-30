class FinalWishesController < AuthenticatedController
  before_action :set_final_wish_info, only: [:show, :edit, :update]
  before_action :set_final_wish, only: [:destroy]
  before_action :set_category_and_group, :set_all_documents, only: [:index, :show, :edit, :new]
  before_action :set_contacts, only: [:new, :edit]
  
  # Breadcrumbs navigation
  add_breadcrumb "Final Wishes", :final_wishes_path, :only => %w(show new edit)
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_edit_crumbs, only: [:edit]
  before_action :set_new_crumbs, only: [:new]
  
  def set_details_crumbs
    return unless @final_wish.final_wishes.any?
    add_breadcrumb "#{@final_wish.group}", final_wish_path(@final_wish)
  end
  
  def set_edit_crumbs
    add_breadcrumb "#{@final_wish.group} Setup", edit_final_wish_path(@final_wish)
  end
  
  def set_new_crumbs
    add_breadcrumb "#{params[:group]} Setup", new_final_wish_path
  end
  
  # GET /final_wishes
  # GET /final_wishes.json
  def index
    @final_wishes = FinalWishInfo.for_user(resource_owner)
    session[:ret_url] = final_wishes_path
  end

  # GET /final_wishes/1
  # GET /final_wishes/1.json
  def show
    @group = FinalWishService.get_wish_group_value_by_id(@groups, params[:id])
    @group_documents = Document.for_user(resource_owner).where(:category => @category, :group => @final_wish.group)
    session[:ret_url] = "#{final_wishes_path}/#{params[:id]}"
  end

  # GET /final_wishes/new
  def new
    @group = FinalWishService.get_wish_group_value_by_name(@groups, params[:group])
    final_wish = FinalWishService.get_wish_info(@group["label"], resource_owner)
    redirect_to "#{final_wishes_path}/#{final_wish[:id]}/edit" if final_wish
    @final_wish_info = FinalWishInfo.new
    @final_wish_info[:group] = params[:group]
    @final_wish_info.final_wishes << FinalWish.new
  end

  # GET /final_wishes/1/edit
  def edit
    @group = FinalWishService.get_wish_group_value_by_id(@groups, @final_wish.id)
    @final_wish_info = @final_wish
  end

  # POST /final_wishes
  # POST /final_wishes.json
  def create
    @final_wish_info = FinalWishInfo.new(final_wish_params.merge(user_id: resource_owner.id))
    FinalWishService.fill_wishes(final_wish_form_params, @final_wish_info, resource_owner.id)
    respond_to do |format|
      if @final_wish_info.save
        format.html { redirect_to session[:ret_url] || final_wishes_path, flash: { success: 'Final Wish was successfully created.' } }
        format.json { render :show, status: :created, location: @final_wish_info }
      else
        format.html { render :new }
        format.json { render json: @final_wish_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /final_wishes/1
  # PATCH/PUT /final_wishes/1.json
  def update
    @final_wish_info = @final_wish
    message = success_message
    FinalWishService.fill_wishes(final_wish_form_params, @final_wish_info, current_user.id)
    respond_to do |format|
      if @final_wish_info.update(final_wish_params)
        format.html { redirect_to session[:ret_url] || final_wishes_path, flash: { success: message } }
        format.json { render :show, status: :ok, location: @final_wish_info }
      else
        format.html { render :edit }
        format.json { render json: @final_wish_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /final_wishes/1
  # DELETE /final_wishes/1.json
  def destroy
    @final_wish.destroy
    respond_to do |format|
      format.html { redirect_to :back || final_wishes_url, notice: 'Final Wish was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def resource_owner
    @final_wish.present? ? @final_wish.user : current_user
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_final_wish
    @final_wish = FinalWish.find(params[:id])
  end
  
  def set_final_wish_info
    @final_wish = FinalWishInfo.find(params[:id])
  end

  def set_category_and_group
    @category = Rails.application.config.x.FinalWishesCategory
    @groups = Rails.configuration.x.categories[@category]["groups"]
    @groups.sort_by { |group| group["label"] }
  end

  def set_all_documents
    @documents = Document.for_user(resource_owner).where(:category => @category)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def final_wish_params
    params.require(:final_wish_info).permit(:id, :group)
  end
  
  def success_message
    return 'Final Wish was successfully created.' unless @final_wish.final_wishes.any?
    'Final Wish was successfully updated.'
  end

  
  def final_wish_form_params
    wishes = params[:final_wish_info].select { |k, _v| k.starts_with?("final_wish_") }
    permitted_params = {}
    wishes.keys.each do |final_wish_key|
      permitted_params[final_wish_key] = [:id, :primary_contact_id, :notes, share_with_contact_ids: []]
    end
    wishes.permit(permitted_params)
  end
end
