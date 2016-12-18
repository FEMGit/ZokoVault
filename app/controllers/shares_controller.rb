class SharesController < AuthenticatedController
    before_action :set_share, only: [:show, :edit, :update, :destroy]

    def index
      @shares_by_user = policy_scope(Share)
                           .each { |s| authorize s }
                           .group_by(&:user)
    end

    def show; end

    def new
      @share = Share.new user: current_user
      authorize @share
    end

    def edit; end

    def create
      @share = Share.new(share_params.merge(user_id: current_user.id))
      authorize @share
      respond_to do |format|
        if @share.save
          format.html { redirect_to @share, notice: 'share was successfully created.' }
          format.json { render :show, status: :created, location: @share }
        else
          format.html { render :new }
          format.json { render json: @share.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      authorize @share

      respond_to do |format|
        if @share.update(share_params)
          format.html { redirect_to @share, notice: 'share was successfully updated.' }
          format.json { render :show, status: :ok, location: @share }
        else
          format.html { render :edit }
          format.json { render json: @share.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @share

      @share.destroy
      respond_to do |format|
        format.html { redirect_to shares_url, notice: 'share was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    def set_share
      @share = Share.for_user(current_user).find(params[:id])
    end

    def share_params
      params.require(:share).permit(:contact_id, :shareable_id, :shareable_type, :permission)
    end
  end
