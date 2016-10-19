class PowerOfAttorneyBuilder

  def initialize(options = {})
    self.power_of_attorney = PowerOfAttorney.new(options.slice(:user_id, :document_id, :name, :powers))
    self.options = options
  end

  def build
    sanitize_data(options[:agent_ids]).each do |contact_id|
      power_of_attorney.vault_entry_contacts.build(
        active: true, type: :power_of_attorney, contact_id: contact_id
      )
    end

    share_options = { document_id: power_of_attorney.document_id, user_id: options[:user_id] }
    sanitize_data(options[:share_ids]).each do |contact_id|
      power_of_attorney.shares.build(share_options.merge(contact_id: contact_id))
    end

    power_of_attorney
  end

  private

  def sanitize_data(data)
    [*data].select &:present?
  end

  attr_internal_accessor :power_of_attorney, :options
end
