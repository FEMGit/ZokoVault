class SharesController < AuthenticatedController
    before_action :set_share, only: [:show, :edit, :update, :destroy]
    helper_method :shared_category_count
    helper_method :shared_document_count
    include UserTrafficModule
    
    def page_name
      case action_name
        when 'index'
          return "Shared With Me"
      end
    end

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
    
    def shared_category_count(shares, user)
      SharedViewService.shared_categories_full(shares).count
    end

    def shared_document_count(shareables, user)
      direct_document_share = shareables.select { |res| res.is_a? Document }
      group_docs = Document.for_user(user).select { |x| (shared_groups(user)["Tax"].include? x.group) ||
                                                        (shared_groups(user)["FinalWish"].include? x.group) ||
                                                        (shared_groups(user)["FinancialProvider"].include? x.financial_information_id) ||
                                                        (shared_groups(user)["Vendor"].include? x.vendor_id) ||
                                                        (shared_groups(user)["Will - POA"].include? x.card_document_id) || 
                                                        (shared_groups(user)["Trusts & Entities"].include? x.card_document_id)}

      category_docs = Document.for_user(user).select { |x| shared_categories(user).include? x.category }
      (group_docs.map(&:id) + direct_document_share.map(&:id) + category_docs.map(&:id)).uniq.count
    end
    
    def shared_groups(user)
      SharedViewService.shared_group_names(user, current_user)
    end
    
    def shared_categories(user)
      SharedViewService.shares(user, current_user).select(&:shareable_type).select { |sh| Object.const_defined?(sh.shareable_type) && (sh.shareable.is_a? Category) }.map(&:shareable).map(&:name)
    end

    def set_share
      @share = Share.for_user(current_user).find(params[:id])
    end

    def share_params
      params.require(:share).permit(:contact_id, :shareable_id, :shareable_type, :permission)
    end
  end
