class SearchController < AuthenticatedController
  PER_PAGE_RECORDS = 10

  def index
    @per_page_records = PER_PAGE_RECORDS
    
    @search_results = 
      if params[:q].present?
        matched_resources = ResourceSearcher.new(
          UserResourceGatherer.new(current_user).my_resources
        ).search(params[:q])
      end

    @paginated_results = 
      Kaminari.paginate_array(@search_results.to_a)
        .page(params[:page])
        .per(PER_PAGE_RECORDS)
  end
end
