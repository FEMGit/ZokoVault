module SearchHelper
  def results_summary
    page = params[:page].to_i
    results_count = @search_results&.length || 0

    start_range = page * @per_page_records
    end_range = start_range + @per_page_records

    # adjust if actual total less than end rage
    if results_count < end_range
      end_range = results_count
    end

    "Results #{start_range}-#{end_range} of #{results_count}"
  end
end
