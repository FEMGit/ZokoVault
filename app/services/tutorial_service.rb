class TutorialService
  def self.update_tutorial_without_dropdown(update_all_params, model, resource_owner)
    return unless update_all_params.present?
    update_all_params.values.each do |update_value|
      object_to_update = model.for_user(resource_owner).find_by(id: update_value[:id])
      next unless trust
      object_to_update.update(update_value)
    end
  end
  
  def self.update_tutorial_with_single_dropdown(update_all_params, model, resource_owner, key)
    return unless update_all_params.present?
    update_all_params.values.each do |update_value|
      object_to_update = model.for_user(resource_owner).find_by(id: update_value[:id])
      next unless object_to_update
      update_params = { id: update_value[:id], name: update_value[:name] }
      update_params.merge!(key =>  update_value[:types].first) if update_value[:types].present?
      object_to_update.update(update_params)
    end
  end
  
  def self.update_tutorial_with_multiple_dropdown(update_all_params, model, resource_owner, key)
    return unless update_all_params.present?
    update_all_params.values.each do |update_value|
      financial_provider = FinancialProvider.for_user(resource_owner).find_by(id: update_value[:id])
      next unless financial_provider
      
      case model.name
        when FinancialAlternative.to_s
          objects_to_update = financial_provider.alternatives
          types_collection = FinancialAlternative::alternative_types
        when FinancialAccountInformation.to_s
          objects_to_update = financial_provider.accounts
          types_collection = FinancialAccountInformation::account_types
      end
      
      return unless objects_to_update.present?
      
      if update_value[:types].present?
        objects_to_update.each do |object_to_update|
          unless (update_value[:types].include? object_to_update.try(:alternative_type) ||object_to_update.try(:account_type))
            object_to_update.destroy
          end
        end

        update_value[:types].each do |type|
          next if (objects_to_update.map { |x| x[key] }.include? types_collection[type]) || type.blank?
          objects_to_update << model.new(:user => resource_owner, key => type)
        end
      end
      financial_provider.update(id: update_value[:id], name: update_value[:name])
    end
  end
  
  def self.set_documents_information(category_name, user, dropdown_option_names = nil)
    @category_dropdown_options = dropdown_option_names.blank? ? Array.wrap(category_name) : dropdown_option_names
    service = DocumentService.new(:category => category_name)
    @card_names = service.get_card_names(user, user)
    @cards = service.get_card_values(user, user)
    [@category_dropdown_options, @card_names, @cards]
  end
end
