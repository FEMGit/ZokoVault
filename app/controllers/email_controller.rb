class EmailController < AuthenticatedController
  include EmailHelper
  
  def share_invitation_mailer_name
    contact = Contact.find_by(id: mailer_preview_params[:contact_id])
    return unless contact
    if(mailer_name = share_mailer_name(current_user, contact)).present?
      render json: { status: 200, name: mailer_name }
    else
      render json: { errors: "Error rendering email preview page." }, status: 500
    end
  end
  
  def email_preview_line
    render :partial => "tutorials/tutorial_share_contact_preview", :locals => { :contact_id => mailer_preview_params[:contact_id] } 
  end
  
  private
  
  def mailer_preview_params
    params.permit(:contact_id)
  end
end