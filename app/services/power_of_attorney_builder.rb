class PowerOfAttorneyBuilder

  def initialize(options = {})
    self.power_of_attorney = get_power_of_attorney(options)
    self.options = options
    options[:id] && options[:id].present? && clear_options
  end
  
  def clear_options
    clear_model
    WtlService.clear_one_option(options)
    power_of_attorney.powers = options[:powers]
  end
  
  def clear_model
    power_of_attorney.agents = []
    power_of_attorney.powers = []
    power_of_attorney.shares = []
  end

  def build
    sanitize_data(options[:agent_ids]).each do |contact_id|
      power_of_attorney.vault_entry_contacts.build(
        active: true, type: :power_of_attorney, contact_id: contact_id
      )
    end

    share_options = { shareable: power_of_attorney.document, user_id: options[:user_id] }
    sanitize_data(options[:share_ids]).each do |contact_id|
      power_of_attorney.shares.build(share_options.merge(contact_id: contact_id))
    end
    
    power_of_attorney.notes = options[:notes]

    power_of_attorney
  end

  private

  def get_power_of_attorney(options)
    if options[:id] && options[:id].present?
      PowerOfAttorney.find(options[:id])
    else
      PowerOfAttorney.new(options.slice(:user_id, :document_id, :name, :powers))
    end
  end
  
  def sanitize_data(data)
    [*data].select &:present?
  end

  attr_internal_accessor :power_of_attorney, :options
end
