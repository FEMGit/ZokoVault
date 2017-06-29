class DocumentDatatable
  delegate :root_url, :params, :link_to, :current_user, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: get_raw_records.count,
      iTotalDisplayRecords: get_raw_records.count,
      data: data
    }
  end

  private
  
  def sort_direction
    params[:order]["0"][:dir] || "desc"
  end
  
  def sort_column
    case params[:order]["0"][:column]
      when "0"
        # Name
        "name "
      when "1"
        # Time
        "updated_at "
      when "2"
        # Page Name
        "category "
      when "3"
        # Url
        "shared_with "
      when "4"
        # Requesting IP
        "notes "
    end
  end
  
  def data
    paginated_records.map do |info|
      [
        traffic_user(info),
        info.created_at.utc.to_s,
        traffic_page(info),
        traffic_url(info),
        info.ip_address
      ]
    end
  end

  def get_raw_records
    Document.for_user(current_user).where(filter).each { |d| authorize d }.order(sort_column + sort_direction)
  end

  def paginated_records
    get_raw_records.page(page).per(per_page).order(:created_at)
  end

  def filter
    filters = []

    query_params = params[:search][:value].split(' ')
    
    all_queries = []
    query_params.each do |query|
      param = "'%#{query}%'"
      columns = %w(name updated_at category shared_with notes)
      all_queries << columns.map { |c| "#{c} ilike #{param}" }
    end
    
    if all_queries.present?
      all_queries = all_queries.join(" OR ").prepend('(') << ')'
      filters << all_queries
    end
    filters.join(" AND ")
  end
  
  def join_query
    "LEFT OUTER JOIN user_profiles AS profiles ON profiles.user_id = " +
      "user_traffics.shared_user_id OR profiles.user_id = user_traffics.user_id"
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
end
