class ActionView::Base attr_accessor :documents end

class DocumentDatatable
  include Rails.application.routes.url_helpers
  include DocumentsHelper
  include SharedViewHelper
  include DateHelper
  delegate :root_url, :params, :link_to, :current_user, :documents, to: :@view

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
        "name "
      when "1"
        "documents.updated_at "
      when "2"
        "category "
      when "3"
        "contacts.lastname "
      when "4"
        "description "
    end
  end
  
  def data
    paginated_records.map do |document|
      [
        document_link(document),
        date_format(document.updated_at),
        document_tag(document),
        document_shared_with(document),
        document_notes(document),
        document_actions(document)
      ]
    end
  end

  def get_raw_records
    #DocumentPolicy::Scope.new(current_user, Document).resolve.joins(join_query).where(filter).order(sort_column + sort_direction)
    document_ids_query = []
    documents.each do |document|
      document_ids_query << "documents.id = #{document.id} "
    end
  
    if document_ids_query.present?
      document_ids_query = document_ids_query.join(" OR ").prepend('(') << ')'
    end
    
    DocumentPolicy::Scope.new(current_user, Document).resolve.joins(join_query).where(document_ids_query).where(filter).order(sort_column + sort_direction)
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
      columns = %w(name category description contacts.firstname contacts.lastname)
      all_queries << columns.map { |c| "#{c} ilike #{param}" }
      all_queries << " to_char(documents.updated_at, 'MM/DD/YYYY') ilike #{param}"
    end
    
    if all_queries.present?
      all_queries = all_queries.join(" OR ").prepend('(') << ')'
      filters << all_queries
    end
    filters.join(" AND ")
  end
  
  def join_query
     "LEFT OUTER JOIN shares on shares.shareable_type='Document' AND shares.shareable_id=documents.id
      LEFT OUTER JOIN contacts on shares.contact_id = contacts.id"
  end
  
  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  
  def document_link(document)
    @view.render(:partial => 'layouts/document_links', :formats => [:html], locals: { document: document })
  end
  
  def document_tag(document)
    @view.render(:partial => 'layouts/document_tags', :formats => [:html], locals: { document: document })
  end
  
  def document_shared_with(document)
    @view.render(:partial => 'layouts/share_with_contacts', locals: { shares: document_shares(document) })
  end
  
  def document_notes(document)
    @view.render(:partial => 'layouts/document_notes', locals: { notes: document.description })
  end
  
  def document_actions(document)
    @view.render(:partial => 'layouts/document_actions', locals: { document: document })
  end
end
