class VendorsController < AuthenticatedController
  before_action :set_vendor, only: [:show, :edit, :update, :destroy]

  # GET /vendors
  # GET /vendors.json
  def index
    @vendors = Vendor.all
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show; end

  # GET /vendors/new
  def new
    @vendor = Vendor.new(base_params.slice(:category, :group))
    @vendor.vendor_accounts.build
  end

  # GET /_new_vendor
  def _newvendor # XXX: What is this? Not RESTFUL
    new
  end

  # GET /vendors/1/edit
  def edit
    if @vendor.vendor_accounts.size==0
      @vendor.vendor_accounts.build
    end
  end

  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Vendor.new(vendor_params.merge(user_id: current_user.id))
    @vendor_accounts = @vendor.vendor_accounts

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to @vendor, notice: 'Vendor was successfully created.' }
        format.json { render :show, status: :created, location: @vendor }
      else
        format.html { render :new }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendors/1
  # PATCH/PUT /vendors/1.json
  def update
    respond_to do |format|
      if @vendor.update(vendor_params)
        format.html { redirect_to @vendor, notice: 'Vendor was successfully updated.' }
        format.json { render :show, status: :ok, location: @vendor }
      else
        format.html { render :edit }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendors/1
  # DELETE /vendors/1.json
  def destroy
    @vendor.destroy
    respond_to do |format|
      format.html { redirect_to vendors_url, notice: 'Vendor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def redirect_to(*payload)
      super *return_to_path(*payload)
    end

    def return_to_path(*payload)
      if base_params[:return] == "insurance"
        payload[0] = insurance_path
      end

      payload
    end
    helper_method :return_to_path
    
    def set_vendor
      @vendor = Vendor.find(params[:id])
    end

    def base_params
      params.permit(:category, :group, :return)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vendor_params
      params.require(:vendor).permit(:category, :group, :name, :webaddress, :phone, :contact_id, :user_id, vendor_accounts_attributes: [:name])
    end
end
