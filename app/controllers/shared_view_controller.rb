class SharedViewController < AuthenticatedController
  include DocumentsHelper 

  layout "shared_view"

  before_action :set_shared_user, :set_shares

  def estate_planning 
    nil
  end

  def dashboard
    @document_shareables, @other_shareables = @shares.map(&:shareable).partition { |s| s.is_a? Document }
  end

  def estate_planning
    @trusts, @wills, @power_of_attorneys, @wtl_documents = [], [], [], []
    groups_whitelist = %w(Trust Will PowerOfAttorney)

    @shares.each do |share|
      case (resource = share.shareable)
      when Trust
        @trusts << resource
      when Will
        @wills << resource
      when PowerOfAttorney
        @power_of_attorneys << resource
      when Document
        if groups_whitelist.include?resource.group
          @wtl_documents << resource
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
end
