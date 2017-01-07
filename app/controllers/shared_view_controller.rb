class SharedViewController < AuthenticatedController
  include DocumentsHelper 

  layout "shared_view"

  before_action :set_shared_user, :set_shares
  before_action :set_shareables
  before_action :set_shared_categories_names

  def dashboard
  end

  def insurance
    nil
  end

  def taxes
    nil
  end

  # GET /final_wishes
  # GET /final_wishes.json
  def final_wishes
    @category = Category.fetch(Rails.application.config.x.FinalWishesCategory.downcase)
    @contacts_with_access = @shared_user.shares.categories.select { |share| share.shareable.eql? @category }.map(&:contact) 

    @final_wishes =
      if @shared_category_names.include? 'Final Wishes'
        FinalWishInfo.for_user(@shared_user)
      else
        @other_shareables.map { |shareable| shareable.is_a?FinalWishInfo }
      end
  end

  def estate_planning
    @trusts, @wills, @power_of_attorneys, @wtl_documents = [], [], [], []
    groups_whitelist = %w(Trust Will PowerOfAttorney)

    @shares.map(&:shareable).each do |shareable| 
      case shareable
      when Trust
        @trusts << shareable
      when Will
        @wills << shareable
      when PowerOfAttorney
        @power_of_attorneys << shareable
      when Document
        if groups_whitelist.include?shareable.group
          @wtl_documents << shareable
        end
      end
    end

    @category = Rails.application.config.x.WtlCategory
    @vault_entries = [@power_of_attorneys, @trusts, @wills].flatten
    @wtl_documents |= @vault_entries.map(&:document).compact
  end

  def wills
    shareables = @shares.map(&:shareable)
    @wills = shareables.select { |resource| resource.is_a? Will }
    @group_documents = shareables.select { |resource| resource.is_a?(Document) && resource.group == "Will" }
  end

  def trusts
    shareables = @shares.map(&:shareable)
    @trusts = shareables.select { |resource| resource.is_a? Trust }
    @group_documents = shareables.select { |resource| resource.is_a?(Document) && resource.group == "Trust" }
  end

  def power_of_attorneys
    shareables = @shares.map(&:shareable)
    @power_of_attorneys = shareables.select { |resource| resource.is_a? PowerOfAttorney }
    @group_documents = shareables.select { |resource| resource.is_a?(Document) && resource.group == "PowerOfAttorney" }
  end

  private

  def set_shared_user 
    @shared_user = User.find(params[:shared_user_id])
  end

  def set_shares
    @shares = policy_scope(Share)
      .where(user: @shared_user)
      .each { |s| authorize s }
  end

  def set_shared_categories_names
    @shared_category_names = @shares.map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
  end

  def set_shareables
    @document_shareables, @category_shareables, @other_shareables = Array.new(3) { [] }

    @shares.map(&:shareable).each do |shareable| 
      case shareable
      when Document
        @document_shareables << shareable
      when Category
        @category_shareables << shareable
      else
        @other_shareables << shareable
      end
    end
  end
end
