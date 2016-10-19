class CategoriesController < AuthenticatedController
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  layout "shared_view", only: [:shared_view_dashboard]
  def index
    @categories = Category.for_user(current_user)
  end
  
  def shared_view_dashboard
  end

  def insurance
    @category = Rails.application.config.x.InsuranceCategory #TODO: fix bug in padding out groups if missing
    @groups = Rails.configuration.x.categories[@category]["groups"]
    @insurance_vendors = Vendor.for_user(current_user).where(category: @category)
    @insurance_documents = Document.for_user(current_user).where(category: @category)
    session[:ret_url] = "/insurance"
  end
  
  
  def estate_planning
    @category = Rails.application.config.x.WtlCategory
    @power_of_attorneys = PowerOfAttorney.for_user(current_user)
    @trusts = Trust.for_user(current_user)
    @wills = Will.for_user(current_user)
    @vault_entries = [@power_of_attorneys, @trusts, @wills].flatten
    vault_documents = @vault_entries.map(&:document)
    @wtl_documents = get_not_assigned_documents(vault_documents)
    session[:ret_url] = "/estate_planning"
  end
  
  def details_account
    @category = params[:category]
    group_for_new_account = params[:group]
    groups = Rails.configuration.x.categories[@category]["groups"]
    @group = groups.detect { |group| group["value"] == group_for_new_account }
    @group_documents = DocumentService.new(:category => @category).get_group_documents(current_user, @group["label"])
  end

  def new_account
    @category = params[:category]
    group_for_new_account = params[:group]
    groups = Rails.configuration.x.categories[@category]["groups"]
    @group = groups.detect { |group| group["value"] == group_for_new_account }
  end
  
  def show
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params.merge(user: current_user))

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_category
    @category = Category.for_user(current_user).find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :managed, :category, :group)
  end
  
  def get_not_assigned_documents(vault_documents)
    Document.for_user(current_user).where(category: @category)
            .where.not(id: vault_documents.compact.map(&:id))
  end
end
