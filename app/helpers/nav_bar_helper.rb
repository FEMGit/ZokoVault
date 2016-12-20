module NavBarHelper
  def controller?(controller_name)
    params[:controller] == controller_name
  end
end
