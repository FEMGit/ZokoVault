class LifeAndDisabilitiesController < AuthenticatedController
  before_action :set_life, only: [:show, :edit, :update, :destroy]
  before_action :set_contacts, only: [:new, :create, :edit, :update]

  # GET /lives
  # GET /lives.json
  def index
    @life_and_disabilities = LifeAndDisability.for_user(current_user)
  end

  # GET /lives/1
  # GET /lives/1.json
  def show
  end

  # GET /lives/new
  def new
    @life_and_disability = LifeAndDisability.new
    @life_and_disability.build_policy
  end

  # GET /lives/1/edit
  def edit
  end

  # POST /lives
  # POST /lives.json
  def create
    @life_and_disability = LifeAndDisability.new(life_params.merge(user_id: current_user.id))
    respond_to do |format|
      if @life_and_disability.save
        format.html { redirect_to insurance_path, notice: 'Life was successfully created.' }
        format.json { render :show, status: :created, location: @life }
      else
        format.html { render :new }
        format.json { render json: @life_and_disability.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lives/1
  # PATCH/PUT /lives/1.json
  def update
    respond_to do |format|
      if @life_and_disability.update(life_params)
        format.html { redirect_to @life_and_disability, notice: 'Life was successfully updated.' }
        format.json { render :show, status: :ok, location: @life }
      else
        format.html { render :edit }
        format.json { render json: @life_and_disability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lives/1
  # DELETE /lives/1.json
  def destroy
    @life_and_disability.destroy
    respond_to do |format|
      format.html { redirect_to lives_url, notice: 'Life was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_life
      @life_and_disability = LifeAndDisability.for_user(current_user).find(params[:id])
    end

    def set_contacts
      @contacts = Contact.for_user(current_user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def life_params
      params.fetch(:life_and_disability).permit!
    end
end
