class WillBuilder

  def initialize(options = {})
    if(options[:id] && !options[:id].empty?)
      self.will = Will.find(options[:id])
    else
      self.will = Will.new(options.slice(:user_id, :document_id, :executor_id))
    end
    self.options = options
    if(options[:id] && !options[:id].empty?)
      clear_options
    end
  end
  
  def clear_options
    clear_model
    will.executor = Contact.find(options[:executor_id])
    WtlService.clear_one_option(options)
  end
  
  def clear_model
    will.agents = []
    will.shares = []
    will.primary_beneficiaries = []
    will.secondary_beneficiaries = []
  end


  def build
    build_beneficiaries

    sanitize_data(options[:agent_ids]).each do |contact_id|
      will.vault_entry_contacts.build(
        active: true, type: :agent, contact_id: contact_id
      )
    end

    share_options = { document_id: will.document_id, user_id: options[:user_id] }
    sanitize_data(options[:share_ids]).each do |contact_id|
      will.shares.build(share_options.merge(contact_id: contact_id))
    end

    will
  end

  private

  def build_beneficiaries
    sanitize_data(options[:primary_beneficiary_ids]).each do |contact_id|
      will.vault_entry_beneficiaries.build(
        active: true, type: :primary, contact_id: contact_id
      )
    end

    sanitize_data(options[:secondary_beneficiary_ids]).each do |contact_id|
      will.vault_entry_beneficiaries.build(
        active: true, type: :secondary, contact_id: contact_id
      )
    end
  end

  def sanitize_data(data)
    [*data].select &:present?
  end

  attr_internal_accessor :will, :options
end
