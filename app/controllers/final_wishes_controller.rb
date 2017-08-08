class FinalWishesController < AuthenticatedController
  include SharedViewModule
  include SharedViewHelper
  include BackPathHelper
  include SanitizeModule
  before_action :set_final_wish_info, only: [:show, :edit, :update]
  before_action :set_final_wish, only: [:destroy]
  before_action :set_category_and_group, :set_all_documents, only: [:index, :show, :edit, :new]
  before_action :set_contacts, only: [:new, :edit]
  before_action :prepare_share_params, only: [:create, :update]

  # Breadcrumbs navigation
  before_action :set_index_breadcrumbs
  before_action :set_details_crumbs, only: [:edit, :show]
  before_action :set_edit_crumbs, only: [:edit]
  before_action :set_new_crumbs, only: [:new]
  include BreadcrumbsCacheModule
  include UserTrafficModule
  include CancelPathErrorUpdateModule
  
  def set_index_breadcrumbs
    add_breadcrumb "Final Wishes", final_wishes_path if general_view?
    add_breadcrumb "Final Wishes", final_wishes_shared_view_path(@shared_user) if shared_view?
  end

  def page_name
    case action_name
      when 'index'
        return "Final Wishes"
      when 'new'
        return "Final Wishes - #{params[:group]} - Setup"
      when 'edit'
        final_wish_info = FinalWishInfo.for_user(resource_owner).find_by(id: params[:id])
        return "Final Wishes - #{final_wish_info.group} - Edit"
      when 'show'
        final_wish_info = FinalWishInfo.for_user(resource_owner).find_by(id: params[:id])
        return "Final Wishes - #{final_wish_info.group} - Details"
    end
  end

  def set_details_crumbs
    return unless @final_wish.final_wishes.any?
    add_breadcrumb "#{@final_wish.group}", final_wish_path(@final_wish) if general_view?
    add_breadcrumb "#{@final_wish.group}", final_wish_shared_view_path(@shared_user, @final_wish) if shared_view?
  end

  def set_edit_crumbs
    add_breadcrumb "#{@final_wish.group} Setup", edit_final_wish_path(@final_wish) if general_view?
    add_breadcrumb "#{@final_wish.group} Setup", edit_final_wish_shared_view_path(@shared_user, @final_wish) if shared_view?
  end

  def set_new_crumbs
    add_breadcrumb "#{params[:group]} Setup", new_final_wish_path if general_view?
    add_breadcrumb "#{params[:group]} Setup", new_final_wish_shared_view_path if shared_view?
  end

  # GET /final_wishes
  # GET /final_wishes.json
  def index
    @category = Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase)
    @contacts_with_access = resource_owner.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact)

    @final_wishes = FinalWishInfo.for_user(resource_owner)
    @final_wishes.each { |fw| fw.final_wishes.each { |f| authorize f } }
    sort_groups(@final_wishes.map(&:group).sort)
    session[:ret_url] = @shared_user.present? ? final_wish_shared_view_path : final_wishes_path
  end

  def sort_groups(existing_group_names)
    all_group_names = @groups.map { |x| x["label"] }
    end_group_names = all_group_names - existing_group_names
    groups = []
    (existing_group_names + end_group_names).each do |group|
      groups.push(@groups.detect { |x| x["label"] == group })
    end
    @groups = groups
  end

  # GET /final_wishes/1
  # GET /final_wishes/1.json
  def show
    @final_wishes = final_wishes
    @final_wishes.each { |fw| authorize fw }
    @group = FinalWishService.get_wish_group_value_by_id(@groups, params[:id])
    @group_documents = Document.for_user(resource_owner).where(:category => @category, :group => @final_wish.group)
    session[:ret_url] = @shared_user.present? ? final_wish_shared_view_path(id: @final_wish.id) : final_wish_path(@final_wish)
  end

  # GET /final_wishes/new
  def new
    @group = FinalWishService.get_wish_group_value_by_name(@groups, params[:group])
    unless @group.present?
      redirect_to final_wishes_shared_view_path and return if shared_view?
      redirect_to final_wishes_path and return
    end
    final_wish = FinalWishService.get_wish_info(@group["label"], resource_owner)
    redirect_to current_user_edit_final_wish_path(final_wish) if final_wish
    @final_wish_info = FinalWishInfo.new(user: resource_owner, category: Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase))
    @final_wish_info[:group] = params[:group]
    @final_wish_info.final_wishes << FinalWish.new(user: resource_owner, category: Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase))
    @final_wishes = @final_wish_info.final_wishes
    @final_wishes.each { |fw| authorize fw }
    set_viewable_contacts
  end
  
  # GET /final_wishes/1/edit
  def edit
    @group = FinalWishService.get_wish_group_value_by_id(@groups, @final_wish.id)
    @final_wish_info = @final_wish
    @final_wishes = final_wishes
    @final_wishes.each { |fw| authorize fw }
    set_viewable_contacts
  end

  # POST /final_wishes
  # POST /final_wishes.json
  def create
    @final_wish_info = FinalWishInfo.new(final_wish_params.merge(user_id: resource_owner.id))
    FinalWishService.fill_wishes(final_wish_form_params, @final_wish_info, resource_owner.id)
    authorize_save
    respond_to do |format|
      if validate_params && @final_wish_info.save
        FinalWishService.update_shares(@final_wish_info, nil, resource_owner)
        success_path(final_wish_path(@final_wish_info), final_wish_shared_view_path(shared_user_id: resource_owner.id, id: @final_wish_info.id))
        format.html { redirect_to @path, flash: { success: 'Final Wish was successfully created.' } }
        format.json { render :show, status: :created, location: @final_wish_info }
      else
        error_path(:new)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @final_wish_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /final_wishes/1
  # PATCH/PUT /final_wishes/1.json
  def update
    @final_wish_info = @final_wish
    @previous_share_with = @final_wish_info.final_wishes.map(&:share_with_contact_ids)
    message = success_message
    FinalWishService.fill_wishes(final_wish_form_params, @final_wish_info, resource_owner.id)
    authorize_save
    respond_to do |format|
      if validate_params && @final_wish_info.update(final_wish_params)
        FinalWishService.update_shares(@final_wish_info, @previous_share_with, resource_owner)
        success_path(final_wish_path(@final_wish_info), final_wish_shared_view_path(shared_user_id: resource_owner.id, id: @final_wish_info.id))
        format.html { redirect_to @path, flash: { success: message } }
        format.json { render :show, status: :ok, location: @final_wish_info }
      else
        error_path(:edit)
        format.html { render controller: @path[:controller], action: @path[:action], layout: @path[:layout] }
        format.json { render json: @final_wish_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /final_wishes/1
  # DELETE /final_wishes/1.json
  def destroy
    authorize @final_wish
    @final_wish.destroy
    respond_to do |format|
      format.html { redirect_to back_path || final_wishes_url, notice: 'Final Wish was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  def current_user_edit_final_wish_path(final_wish)
    return edit_final_wish_path(final_wish) unless @shared_user
    edit_final_wish_shared_view_path(@shared_user, final_wish.id)
  end

  def validate_params
    final_wish_groups = Rails.application.config.x.categories.select { |k, v| k == Rails.application.config.x.FinalWishesCategory }.values
    final_wish_groups.map! {|x| x["groups"]}.flatten!.map! {|x| x["label"]}
    final_wish_groups.include? @final_wish_info.group
  end

  def set_viewable_contacts
    @final_wishes.each do |final_wish|
      final_wish.share_with_contact_ids |= category_subcategory_shares(final_wish, resource_owner).map(&:contact_id)
    end
  end

  def prepare_share_params
    viewable_shares = full_category_shares(Category.fetch(Rails.application.config.x.FinalwishesCategory.downcase), resource_owner).map(&:contact_id).map(&:to_s)
    final_wish_form_params.each do |k, v|
      if v["share_with_contact_ids"].present?
        v["share_with_contact_ids"] -= viewable_shares
      end
    end
  end

  def authorize_save
    authorize_ids = final_wish_form_params.values.map { |x| x[:id].to_i }
    @final_wish_info.final_wishes.where(:id => authorize_ids).each { |t| authorize t }
  end

  def final_wishes
    return @final_wish.final_wishes if @shared_user.nil? || (@shared_category_names.include? 'Final Wishes')
    contact_ids = Contact.where("emailaddress ILIKE ?", current_user.email).map(&:id)
    shared_ids = FinalWish.for_user(resource_owner).select { |t| t.share_with_contact_ids.any? { |c_id| contact_ids.include? c_id } }.map(&:id)
    @final_wish.final_wishes.select { |t| shared_ids.include? t.id }
  end

  def shared_user_params
    params.permit(:shared_user_id)
  end

  def error_path(action)
    @path = ReturnPathService.error_path(resource_owner, current_user, params[:controller], action)
    @shared_user = ReturnPathService.shared_user(@path)
    @shared_category_names = ReturnPathService.shared_category_names(@path)
  end

  def success_path(common_path, shared_view_path)
    @path = ReturnPathService.success_path(resource_owner, current_user, common_path, shared_view_path)
  end

  def resource_owner
    if shared_user_params[:shared_user_id].present?
      User.find_by(id: params[:shared_user_id])
    else
      @final_wish.present? ? @final_wish.user : current_user
    end
  end

  def set_contacts
    contact_service = ContactService.new(:user => resource_owner)
    @contacts = contact_service.contacts
    @contacts_shareable = contact_service.contacts_shareable
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
