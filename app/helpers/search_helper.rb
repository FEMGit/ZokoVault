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
  
  def absolute_path(relative_path)
    root_url.chomp('/') + relative_path
  end
  
  def resource_link(resource)
    if resource.is_a? Contact
      profile_for_current_user = UserProfile.find_by(user_id: current_user.id)
      if resource.user_profile_id.present? && (resource.user_profile_id.eql? profile_for_current_user.id)
        return my_profile_path
      else
        return url_for(resource)
      end
    end
    
    if subcategory_view_path(resource).present?
      subcategory_view_path(resource)
    elsif resource.try(:attributes)
      url_for(resource)
    else
      url_for(resource[:path])
    end
  end
  
  def results_any?
    @search_results.any?
  end
  
  def entity_name(resource)
    if resource[:name].present?
      return resource[:name]
    end
    
    case resource
    when Contact, Document, Category
      resource.name
    else
      subcategory_name(resource)
    end
  end
  
  def entity_info(resource)
    if resource.try(:attributes)
      response_format(resource)
    elsif resource[:name].present?
      "#{resource[:name]} - Category"
    else
      nil
    end
  end
  
  private
  
  def response_format(resource)
    full_response = resource.attributes.reject { |k, v| k.index("id").present? || v.blank? }
                                       .map { |k,v| "#{k}:#{v}" }.join(", ").prepend("…")
    index_of_match = full_response.downcase.index(params[:q])
    
    return if index_of_match.nil?
    
    before = full_response[0...index_of_match]
    match = full_response[index_of_match...index_of_match + params[:q].length]
    after = full_response[index_of_match + params[:q].length...full_response.length]

    match_tag = content_tag(:b, match).html_safe

    content_tag(:span, class: 'result-text') do
      before.concat(match_tag).concat(after).html_safe
    end
  end
end
