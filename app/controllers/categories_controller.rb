class CategoriesController < AuthenticatedController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.for_user(current_user)
  end

  def insurance
    @category = "insurance" #TODO: fix bug in padding out groups if missing
    @groups = Rails.configuration.x.categories[@category]["groups"]
    @group_pivot = {      #TODO: Turn label/key attributes into hash programmatically
      "life" => "Life & Disability Insurance",
      "property" => "Property Insurance",
      "health" => "Health Insurance"
    }
    @insurance_vendors = Vendor.for_user(current_user).where(category: @category)
    @insurance_documents = Document.for_user(current_user).where(category: @category)
    session[:ret_url] = "insurance"
  end

  def show
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)
    @category.user = current_user

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
end
