module NavBarHelper
  def controller?(*controller_names)
    controller_names.any? { |controller_name| params[:controller] == controller_name }
  end
  
  def breadcrumb?(path)
    return false unless @breadcrumbs.present?
    @breadcrumbs.any? { |breadcrumb| breadcrumb.path == path }
  end
  
  def document_breadcrumb_free?
    return true unless @breadcrumbs.present?
    paths = @breadcrumbs.map(&:path)
    # 1 - we get add/edit document page by url
    # 2 - we get to add/edit document page from documents main page
    paths.count == 1 || 
      paths.count == 2 && paths.any? { |path| path == :documents_path }
  end
end
