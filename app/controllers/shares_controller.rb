class SharesController < ApplicationController
    before_action :set_share, only: [:show, :edit, :update, :destroy]

    def index
      @shares = Share.all
    end

    def show
    end

    def new
      @share = Share.new
    end

    def edit
    end

    def create
      @share = Share.new(share_params.merge(user_id: current_user.id))

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
      params.require(:share).permit(:contact_id, :document_id, :permission)
    end
  end
