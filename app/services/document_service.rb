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
    vendor_group_value = @all_groups.detect{|x| x[:label] == @category.name}[:groups].select{ |x| x['label'] == group }.first["value"]
    document_ids = Vendor.for_user(user).where(:category => @category, :group => vendor_group_value, :id => id)
                                        .collect(&:document_ids).flatten
    Document.for_user(user).find(document_ids)
  end
  
  def get_financial_documents(user, id)
    Document.for_user(user).where(:category => @category, :financial_information_id => id)
  end
  
  def get_all_groups
    @all_groups = Rails.configuration.x.categories.collect{|category| {:label => category[1]["label"], :groups => category[1]["groups"]}}
  end
  
  def category_exist?
    @all_groups.detect{|x| x[:label] == @category}
  end
  
  def group_exist?(group)
    @all_groups.detect { |x| x[:label] == @category.name && x[:groups] }[:groups].any? { |gr| gr["label"] == group}
  end

  def get_empty_card_values
    [id: "Select...", name: "Select..."]
  end
  
  def contact_category?
    @category == "Contact"
  end
  
  def get_card_values(user, current_user = nil)
    get_all_groups
    return [get_empty_card_values] unless category_exist?

    card_values = 
      if contact_category?
        Contact.for_user(user).collect{|x| [id: x.id, name: x.name]}
      else
        if user == current_user
          @all_groups.detect{|x| x[:label] == @category}[:groups].collect{ |x| [id: x["label"], name: x["label"]] }
        else
          shared_user_values(user, current_user)
        end
      end
    card_values.prepend(get_empty_card_values)
  end
  
  def shared_user_values(user, current_user)
    shares = SharedViewService.shares(user, current_user).map(&:shareable).select { |s| s.is_a? Category }.map(&:name)
    if shares.include? @category
      @all_groups.detect{|x| x[:label] == @category}[:groups].collect{|x| [id: x["label"], name: x["label"]]}
    else
      groups = SharedViewService.shared_group_names(user, current_user, @category)
      return [get_empty_card_values] unless groups.present?
      groups.collect{|x| [id: x, name: x]}
    end
  end
  
  def get_card_names(user, current_user = nil)
    get_all_groups
    return [] unless category_exist?
    card_names(user, current_user)
  end
  
  def self.get_share_with_documents(user, contact_id)
    Document.for_user(user).select{ |doc| doc.contact_ids.include?(contact_id) }
  end
  
  def self.get_contact_documents(user, category, contact_id)
    Document.where(user: user, category: category, group: contact_id)
  end
  
  def self.empty_value
    "Select..."
  end
  
  def self.update_group?(group, category)
    ![Rails.configuration.x.InsuranceCategory, Rails.configuration.x.FinancialInformationCategory].include? category
  end
  
  private
  
  def card_names(user, current_user = nil)
    if @category == Rails.configuration.x.InsuranceCategory
      vendors = user_cards(Vendor, user, current_user)
      collect_card_names(vendors, Rails.configuration.x.InsuranceCategory)
    elsif @category == Rails.configuration.x.FinancialInformationCategory
      providers = user_cards(FinancialProvider, user, current_user)
      collect_card_names(providers, Rails.configuration.x.FinancialInformationCategory)
    else
      []
    end
  end
  
  def user_cards(model, user, current_user)
    return model.for_user(user).where(:category => Category.fetch(@category.downcase)) unless current_user != user
    model.for_user(user).select{ |x| user_contacts(x, current_user).present?}
  end
  
  def user_contacts(user, current_user)
    Contact.find(user.share_with_contact_ids) & Contact.where(emailaddress: current_user.email)
  end

  def collect_card_names(collection, category)
    collection.collect { |x| [id: x.id, name: x.name] }.prepend([id: category, name: "Select..."])
  end
  
  def self.update_shares(document, resource_owner, previous_document = nil)
    if document.vendor_id.present? && document.vendor_id > 0
      model = Vendor.find_by(id: document.vendor_id).class
      share_contact_ids_to_remove = share_ids_to_remove(previous_document, resource_owner)
    elsif document.financial_information_id.present? && document.financial_information_id > 0
      FinancialProvider.find_by(id: document.financial_information_id).class
    elsif document.group.present?
      model = ModelService.model_by_name(document.group)
      share_contact_ids_to_remove = share_ids_to_remove(previous_document, resource_owner)
    else
      document.contact_ids = []
    end

    unless model.present?
      document.contact_ids = []
      return
    end
    
    document.contact_ids = document.contact_ids.reject { |contact_id| share_contact_ids_to_remove.include? contact_id }
    push_new_shares(model, document, resource_owner)
  end
  
  def self.share_ids_to_remove(previous_document, resource_owner)
    return [] unless previous_document.present? && (previous_document.group.present? ||
      previous_document.vendor_id.present?)
    
    previous_model = previous_model(previous_document, resource_owner)
    return [] unless previous_model.present?
    previous_model_shares(previous_model, resource_owner, previous_document)
  end
  
  def self.push_new_shares(model, document, resource_owner)
    if model == FinalWish
      final_wish_info = FinalWishInfo.for_user(resource_owner).where(:group => document.group).first
      return unless final_wish_info.present?
      document.contact_ids |= final_wish_info.final_wishes.map(&:share_with_contact_ids).flatten
    elsif model == Tax
      tax_year_info = TaxYearInfo.for_user(resource_owner).where(:year => document.group).first
      return unless tax_year_info.present?
      document.contact_ids |= tax_year_info.taxes.map(&:share_with_contact_ids).flatten
    else
      document.contact_ids |= model.for_user(resource_owner).map(&:share_with_contact_ids).flatten
    end
  end
  
  def self.previous_model(previous_document, resource_owner)
    previous_model = 
      if previous_document.vendor_id.present? && previous_document.vendor_id > 0
        Vendor.find_by(id: previous_document.vendor_id).class
      elsif previous_document.financial_information_id.present? && previous_document.financial_information_id > 0
        FinancialProvider.find_by(id: previous_document.financial_information_id).class
      elsif previous_document.group.present?
        ModelService.model_by_name(previous_document.group)
      end
  end
  
  def self.previous_model_shares(model, resource_owner, document)
    if model == FinalWish
      final_wish_info = FinalWishInfo.for_user(resource_owner).where(:group => document.group).first
      return [] unless final_wish_info.present?
      final_wish_info.final_wishes.map(&:share_with_contact_ids).flatten
    elsif previous_model == Tax
      tax_year_info = TaxYearInfo.for_user(resource_owner).where(:year => previous_document.group).first
      return [] unless tax_year_info.present?
      tax_year_info.taxes.map(&:share_with_contact_ids).flatten
    else
      previous_model.for_user(resource_owner).map(&:share_with_contact_ids).flatten
    end
  end
end