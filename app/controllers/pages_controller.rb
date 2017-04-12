class PagesController < HighVoltage::PagesController
  layout 'blank_layout'

  def confirmation; end

  def show
    @tutorial_name = params[:tutorial_id]
    @tutorial      = Tutorial.find_by(name: @tutorial_name.split("-").join(" ").humanize)
    @page_id       = params[:page_id]
    @page_name     = "page_#{params[:page_id]}"
    @next_page     = params[:page_id].to_i + 1
    @confirmation  = false

    if params[:page_id].to_i == @tutorial.number_of_pages
      if session[:order_params].present?
        @next_tutorial = Tutorial.find(session[:order_params].shift)
        @current_tutorial_name = @next_tutorial.name.parameterize
      else
        @confirmation = true
      end
    end
  end
end
