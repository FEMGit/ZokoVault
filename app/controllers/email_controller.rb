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
    user = Thread.current[:current_user]
    contact = Contact.for_user(user).find_by(id: mailer_preview_params[:contact_id])
    submit_button_text = mailer_preview_params[:submit_button_text].eql?('Save') ? 'Save' : 'Continue'
    unless ShareInvitationSent.find_by(user_id: user.try(:id), contact_email: contact.try(:emailaddress))
      render :partial => "layouts/share_contact_preview", :locals => { :contact_id => mailer_preview_params[:contact_id],
                                                                       :submit_button_text => submit_button_text } 
    else
      render :json => ''
    end
  end
  
  private
  
  def mailer_preview_params
    params.permit(:contact_id, :submit_button_text)
  end
end