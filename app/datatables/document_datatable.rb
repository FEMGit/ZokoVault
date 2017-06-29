class DocumentDatatable
  include Rails.application.routes.url_helpers
  include DocumentsHelper
  include SharedViewHelper
  include ActionView::Helpers::TagHelper
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
    paginated_records.map do |document|
      [
        document_link(document),
        document.updated_at,
        document_tag(document)
      ]
    end
  end

  def get_raw_records
    DocumentPolicy::Scope.new(current_user, Document).resolve.where(filter).order(sort_column + sort_direction)
  end

  def paginated_records
    get_raw_records.page(page).per(per_page)
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
  
  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  
  def document_link(document)
    if @shared_user.present?
      link_to document.name, shared_documents_path(@shared_user, document)
    else
      link_to document.name, document_path(document)
    end
  end
  
  def document_tag(document)
    if document.is_a? Document
      if document_category(document).nil?
        content_tag(:span, empty_group_category, class: 'doc-tag')
      else
        primary_tag = content_tag(:span, document_category(document), class: 'doc-tag')
        secondary_tag = 
          if subcategory_shared?(document.user, current_user, document)
            if document_name_tag(document)
              content_tag(:span, document_name_tag(document), class: 'doc-tag secondary-tag')
            elsif document_group(document)
              content_tag(:span, document_group(document), class: 'doc-tag secondary-tag')
            else
              nil
            end
          end
        primary_tag + secondary_tag
      end
    end
  end
end
