class SharesController < AuthenticatedController
    before_action :set_share, only: [:show, :edit, :update, :destroy]
    skip_before_action :redirect_if_free_user
    helper_method :shared_category_count
    helper_method :shared_document_count
    include UserTrafficModule
    include SharedUserExpired
    
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
      ShareService.append_primary_shares(current_user, @shares_by_user)
    end
    
    
    def shared_category_count(shares, user)
      return Rails.application.config.x.ShareCategories.count if current_user.primary_shared_with? user
      (SharedViewService.shared_categories_full(shares) - SharedViewModule.primary_shared_with_category_names).count
    end

    def shared_document_count(shareables, user)
      return Document.for_user(user).count if current_user.primary_shared_with? user
      user_documents = Document.for_user(user)
      user_shared_groups = shared_groups(user)
      user_shared_categories = shared_categories(user)
      direct_document_share = shareables.select { |res| res.is_a? Document }
      group_docs = user_documents.select { |x| (user_shared_groups["Tax"].include? x.group) ||
                                                        (user_shared_groups["FinalWish"].include? x.group) ||
                                                        (user_shared_groups["FinancialProvider"].include? x.financial_information_id) ||
                                                        (user_shared_groups["Vendor"].include? x.vendor_id) ||
                                                        (user_shared_groups["Will - POA"].include? x.card_document_id) || 
                                                        (user_shared_groups["Trusts & Entities"].include? x.card_document_id)}

      category_docs = user_documents.select { |x| user_shared_categories.include? x.category }
      (group_docs.map(&:id) + direct_document_share.map(&:id) + category_docs.map(&:id)).uniq.count
    end
    
    def shared_groups(user)
      SharedViewService.shared_group_names(user, current_user)
    end
    
    def shared_categories(user)
      SharedViewService.shares(user, current_user).select(&:shareable_type).select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
    end

    def set_share
      @share = Share.for_user(current_user).find(params[:id])
    end

    def share_params
      params.require(:share).permit(:contact_id, :shareable_id, :shareable_type, :permission)
    end
  end
