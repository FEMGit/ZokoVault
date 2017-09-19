class UserTrafficDatatable
  delegate :user_link, :resource_link, :root_url, :params, :link_to,
    :params, :current_user, to: :@view

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
        # User Name
        "profiles.last_name " + sort_direction + ", profiles.first_name "
      when "1"
        # Time
        "created_at "
      when "2"
        # Page Name
        "page_name "
      when "3"
        # Url
        "page_url "
      when "4"
        # Requesting IP
        "ip_address "
      else
        "created_at "
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
    ## for_user + shared_traffic
    UserTraffic.joins(join_query).where(filter).includes(user: [user_profile: :contact]).order(sort_column + sort_direction)
  end

  def paginated_records
    get_raw_records.page(page).per(per_page).order(:created_at)
  end

  def filter
    filters = []
    filters << "(user_traffics.user_id = #{current_user.id} OR user_traffics.shared_user_id = #{current_user.id})"

    query_params = params[:search][:value].split(' ')
    
    all_queries = []
    query_params.each do |query|
      param = "'%#{query}%'"
      columns = %w(page_name page_url ip_address profiles.first_name profiles.last_name)
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

  def traffic_user(info)
    link_to info.user.name, user_link(info), class: 'no-underline-link'
  end

  def traffic_page(info)
    return info.page_name if resource_link(info).eql? '--'
    link_to info.page_name, resource_link(info), class: 'no-underline-link'
  end

  def traffic_url(info)
    return '--' if resource_link(info).eql? '--'
    link_name = resource_link(info).remove(root_url).blank? ? "/" : resource_link(info).remove(root_url)
    link_to link_name, resource_link(info), class: 'no-underline-link'
  end
end
