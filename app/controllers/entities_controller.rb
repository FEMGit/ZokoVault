class EntitiesController < AuthenticatedController

  # General Breadcrumbs
  add_breadcrumb "Trusts & Entities", :trusts_entities_path, :only => %w(new edit show)
  add_breadcrumb "Entity - Setup", :new_entity_path, :only => %w(new)
  add_breadcrumb "Entity 1", :entity_path, :only => %w(show edit)
  add_breadcrumb "Entity - Setup", :edit_entity_path, :only => %w(edit)
  
  def show; end
  
  def edit
    @contact = Contact.new(user: current_user)
  end
  
  def new
    @contact = Contact.new(user: current_user)
  end
end