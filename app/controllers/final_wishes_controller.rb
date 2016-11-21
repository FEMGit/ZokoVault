class FinalWishesController < AuthenticatedController
  before_action :set_final_wish_info, only: [:show, :edit, :update]
  before_action :set_final_wish, only: [:destroy]
  before_action :set_category_and_group, :set_all_documents, only: [:index, :show, :edit]
  before_action :set_contacts, only: [:new, :edit]

  # GET /final_wishes
  # GET /final_wishes.json
  def index
    @final_wishes = FinalWishInfo.for_user(current_user)
    session[:ret_url] = final_wishes_path
  end

  # GET /final_wishes/1
  # GET /final_wishes/1.json
  def show
    @group = @groups[params[:id].to_i]
    @group_documents = Document.for_user(current_user).where(:category => @category, :group => @final_wish.group)
    session[:ret_url] = "#{final_wishes_path}/#{params[:id]}"
  end

  # GET /final_wishes/new
  def new
    group = params[:group]
    final_wish = FinalWishService.get_wish_info(group, current_user)
    redirect_to "#{final_wishes_path}/#{final_wish[:id]}/edit" if final_wish
    @final_wish_info = FinalWishInfo.new
    @final_wish_info[:group] = params[:group]
    @final_wish_info.final_wishes << FinalWish.new
  end

  # GET /final_wishes/1/edit
  def edit
    @final_wish_info = @final_wish
  end

  # POST /final_wishes
  # POST /final_wishes.json
  def create
    final_wishes = final_wish_form_params
    final_wishes.keys.each { |x| params[:final_wish_info].delete(x) }
    @final_wish_info = FinalWishInfo.new(final_wish_params.merge(user_id: current_user.id))
    FinalWishService.fill_wishes(final_wishes, @final_wish_info, current_user.id)
    respond_to do |format|
      if @final_wish_info.save
        format.html { redirect_to session[:ret_url] || final_wishes_path, notice: 'Final wish was successfully created.' }
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
    final_wishes = final_wish_form_params
    final_wishes.keys.each { |x| params[:final_wish_info].delete(x) }
    @final_wish_info = @final_wish
    FinalWishService.fill_wishes(final_wishes, @final_wish_info, current_user.id)
    respond_to do |format|
      if @final_wish_info.update(final_wish_params)
        format.html { redirect_to session[:ret_url] || final_wishes_path, notice: 'Final wish was successfully updated.' }
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
      format.html { redirect_to :back || final_wishes_url, notice: 'Final wish was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_contacts
    contact_service = ContactService.new(:user => current_user)
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
    @documents = Document.for_user(current_user).where(:category => @category)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def final_wish_params
    params.require(:final_wish_info).permit!
  end
  
  def final_wish_form_params
    final_wish_params.select { |k, _v| k.starts_with?("final_wish_") }
  end
end
