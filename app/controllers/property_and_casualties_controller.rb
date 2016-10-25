class PropertyAndCasualtiesController < AuthenticatedController
  before_action :set_property_and_casualty, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]

  # GET /properties
  # GET /properties.json
  def index
    @property_and_casualties = PropertyAndCasualty.all
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
  end

  # GET /properties/new
  def new
    @property_and_casualty = PropertyAndCasualty.new
    @property_and_casualty.build_policy
  end

  # GET /properties/1/edit
  def edit
  end

  # POST /properties
  # POST /properties.json
  def create
    @property_and_casualty = PropertyAndCasualty.new(property_and_casualty_params.merge(user_id: current_user.id))

    respond_to do |format|
      if @property_and_casualty.save
        format.html { redirect_to insurance_path, notice: 'PropertyAndCasualty was successfully created.' }
        format.json { render :show, status: :created, location: @property_and_casualty }
      else
        format.html { render :new }
        format.json { render json: @property_and_casualty.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /properties/1
  # PATCH/PUT /properties/1.json
  def update
    respond_to do |format|
      if @property_and_casualty.update(property_and_casualty_params)
        format.html { redirect_to @property_and_casualty, notice: 'PropertyAndCasualty was successfully updated.' }
        format.json { render :show, status: :ok, location: @property_and_casualty }
      else
        format.html { render :edit }
        format.json { render json: @property_and_casualty.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    @property_and_casualty.destroy
    respond_to do |format|
      format.html { redirect_to properties_url, notice: 'PropertyAndCasualty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_property_and_casualty
      @property_and_casualty = PropertyAndCasualty.find(params[:id])
    end

    def set_contacts
      @contacts = Contact.for_user(current_user)
    end

    def property_and_casualty_params
      params.require(:property_and_casualty).permit!
    end
end
