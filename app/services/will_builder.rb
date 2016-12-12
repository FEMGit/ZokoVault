class WillBuilder

  def initialize(options = {})
    self.will = 
      if options[:id].present?
        Will.find(options[:id])
      else
        Will.new(options.slice(:user_id, :document_id, :executor_id))
      end
    self.options = options
    clear_options if options[:id].present?
  end
  
  def clear_options
    clear_model
    contact = Contact.find(options[:executor_id]) if options[:executor_id].present?
    will.executor = contact
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

    share_options = { shareable: will.document, user_id: options[:user_id] }
    sanitize_data(options[:share_ids]).each do |contact_id|
      will.shares.build(share_options.merge(contact_id: contact_id))
    end
    
    will.notes = options[:notes]

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
