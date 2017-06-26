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
      
      objects_to_update = 
        case model.name
          when FinancialAlternative.to_s
            financial_provider.alternatives
          when FinancialAccountInformation.to_s
            financial_provider.accounts
        end
      
      return unless objects_to_update.present?
      
      objects_to_update.each do |object_to_update|
        unless (update_value[:types].include? object_to_update.try(:alternative_type) || object_to_update.try(:account_type))
          object_to_update.destroy
        end
      end
      
      update_value[:types].each do |type|
        next if (objects_to_update.map { |x| x[key] } .include? type)
        objects_to_update << model.new(:user => resource_owner, key => type)
      end
      financial_provider.update(id: update_value[:id], name: update_value[:name])
    end
  end
end
