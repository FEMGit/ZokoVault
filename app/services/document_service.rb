class DocumentService
  
  attr_accessor :document
  
  def initialize(params)
    @category = params[:category]
  end
  
  def get_group_documents(user, group)
    Document.for_user(user).where(:category => @category, :group => group)
  end
  
  def get_all_insurance_category_documents_count(user, group, vendor_ids)
    user_group_vendors = Vendor.for_user(user).where(group: group)
    return 0 unless user_group_vendors.present?
    user_group_vendors.where(:id => vendor_ids).collect(&:document_ids).flatten.count
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
        ContactService.new(:user => user).contacts_shareable.collect{|x| [id: x.id, name: x.name]}
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
    shares = 
      if current_user.primary_shared_with?(user)
        Rails.application.config.x.ShareCategories.dup
      else
        SharedViewService.shares(user, current_user).select(&:shareable_type).select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
      end
    if shares.include? @category
      @all_groups.detect{|x| x[:label] == @category}[:groups].collect{|x| [id: x["label"], name: x["label"]]}
    else
      groups = SharedViewService.shared_group_names(user, current_user, @category)
      return [get_empty_card_values] unless groups.present?
      groups.values.flatten.collect{|x| [id: x, name: x]}
    end
  end
  
  def get_card_names(user, current_user = nil)
    get_all_groups
    return [] unless category_exist?
    card_names(user, current_user)
  end
  
  def self.contact_documents(user, category, contact_id)
    Document.where(user: user, category: category, group: contact_id)
  end
  
  def self.empty_value
    "Select..."
  end
  
  def self.category_or_group_changed?(document, new_category, new_group, new_financial_information_id, new_vendor_id, new_wills_poa_id)
    if new_category == Rails.configuration.x.InsuranceCategory
      return true if (document.category != new_category) || (document.vendor_id != new_vendor_id.try(:to_i))
    elsif new_category == Rails.configuration.x.FinancialInformationCategory
      return true if (document.category != new_category) || (document.financial_information_id != new_financial_information_id.try(:to_i))
    elsif (new_category == Rails.configuration.x.WillsPoaCategory) || (new_category == Rails.configuration.x.TrustsEntitiesCategory)
      return true if (document.category != new_category) || (document.card_document_id != new_wills_poa_id.try(:to_i))
    else
      return true if (document.category != new_category) || (document.group != new_group)
    end
    return false
  end
  
  def self.update_group?(group, category)
    ![Rails.configuration.x.InsuranceCategory, Rails.configuration.x.FinancialInformationCategory, 
      Rails.configuration.x.WillsPoaCategory, Rails.configuration.x.TrustsEntitiesCategory].include? category
  end
  
  private
  
  def card_names(user, current_user = nil)
    if @category == Rails.configuration.x.InsuranceCategory
      vendors = user_cards(Vendor, user, current_user)
      collect_card_names(vendors, Rails.configuration.x.InsuranceCategory)
    elsif @category == Rails.configuration.x.FinancialInformationCategory
      providers = user_cards(FinancialProvider, user, current_user)
      collect_card_names(providers, Rails.configuration.x.FinancialInformationCategory)
    elsif (@category == Rails.configuration.x.WillsPoaCategory)
      wills_poa = user_cards(CardDocument, user, current_user).select { |c| (c.object_type.eql? 'Will') ||
                                                                            (c.object_type.eql? 'PowerOfAttorneyContact')}
      collect_card_names(wills_poa, @category)
    elsif (@category == Rails.configuration.x.TrustsEntitiesCategory)
      wills_poa = user_cards(CardDocument, user, current_user).select { |c| (c.object_type.eql? 'Trust') ||
                                                                            (c.object_type.eql? 'Entity') }
      collect_card_names(wills_poa, @category)
    else
      []
    end
  end
  
  def user_cards(model, user, current_user)
    contact_user = Contact.for_user(user).find_by(emailaddress: current_user.try(:email))
    return model.for_user(user).where(:category => Category.fetch(@category.downcase)) if current_user.primary_shared_with_or_owner? user
    share_categories = user.shares.select(&:shareable_type).select { |sh| (sh.shareable.is_a? Category) && (sh.contact_id == contact_user.try(:id)) }.map(&:shareable).map(&:name)
    return model.for_user(user) if (share_categories.include? @category)
    
    model.for_user(user).select{ |x| user_contacts(x, current_user).present?}
  end
  
  def user_contacts(object, current_user)
    Contact.find(object.share_with_contact_ids) & Contact.where("emailaddress ILIKE ?", current_user.email)
  end

  def collect_card_names(collection, category)
    collection.collect { |x| [id: x.id, name: x.try(:name)] }.prepend([id: category, name: "Select..."])
  end
end