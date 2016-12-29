class DocumentService
  
  attr_accessor :document
  
  def initialize(params)
    @category = params[:category]
  end
  
  def get_group_documents(user, group)
    Document.for_user(user).where(:category => @category, :group => group)
  end
  
  def get_insurance_documents(user, group, id)
    get_all_groups
    vendor_group_value = @all_groups.detect{|x| x[:label] == @category}[:groups].select{ |x| x['label'] == group }.first["value"]
    document_ids = Vendor.for_user(user).where(:category => @category, :group => vendor_group_value, :id => id)
                                        .collect(&:document_ids).flatten
    Document.for_user(user).find(document_ids)
  end
  
  def get_all_groups
    @all_groups = Rails.configuration.x.categories.collect{|category| {:label => category[1]["label"], :groups => category[1]["groups"]}}
  end
  
  def category_exist?
    @all_groups.detect{|x| x[:label] == @category}
  end
  
  def group_exist?(group)
    @all_groups.detect { |x| x[:label] == @category && x[:groups] }[:groups].any? { |gr| gr["label"] == group}
  end

  def get_empty_card_values
    [id: "Select...", name: "Select..."]
  end
  
  def contact_category?
    @category == "Contact"
  end
  
  def get_card_values(user)
    get_all_groups
    return [get_empty_card_values] unless category_exist?

    card_values = 
      if contact_category?
        Contact.for_user(user).collect{|x| [id: x.id, name: x.name]}
      else
        @all_groups.detect{|x| x[:label] == @category}[:groups].collect{|x| [id: x["label"], name: x["label"]]}
      end
    card_values.prepend(get_empty_card_values)
  end
  
  def get_card_names(user)
    get_all_groups
    return [get_empty_card_values] unless category_exist?
    vendors = Vendor.for_user(user).where(:category => @category).order(:group => 'desc')
    return [] unless vendors.present?
    vendors.collect { |x| [id: x.id, name: x.name] }.prepend(get_empty_card_values)
  end

  def self.get_share_with_documents(user, contact_id)
    Document.for_user(user).select{ |doc| doc.contact_ids.include?(contact_id) }
  end
  
  def self.get_contact_documents(user, category, contact_id)
    Document.where(user: user, category: category, group: contact_id)
  end
end
