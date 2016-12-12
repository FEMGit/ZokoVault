class TrustBuilder

  def initialize(options = {})
    self.trust = 
      if options[:id].present?
        Trust.find(options[:id])
      else
        Trust.new(options.slice(:user_id, :document_id, :name))
      end

    self.options = options

    clear_options if options[:id].present?
  end
  
  def clear_options
    clear_model
    WtlService.clear_one_option(options)
  end
  
  def clear_model
    return unless options[:name].present?
    trust.agent_ids = []
    trust.share_with_contacts = []
  end
  
  def build
    build_trustees
    sanitize_data(options[:agent_ids]).each do |contact_id|
      trust.vault_entry_contacts.build(
        active: true, type: :agent, contact_id: contact_id
      )
    end
    share_options = { shareable: trust.document, user_id: options[:user_id] }
    sanitize_data(options[:share_ids]).each do |contact_id|
      trust.shares.build(share_options.merge(contact_id: contact_id))
    end
    set_options
    trust
  end

  private

  def build_trustees
    sanitize_data(options[:trustee_ids]).each do |contact_id|
      trust.vault_entry_contacts.build(
        active: true, type: :trustee, contact_id: contact_id
      )
    end

    sanitize_data(options[:successor_trustee_ids]).each do |contact_id|
      trust.vault_entry_contacts.build(
        active: true, type: :successor_trustee, contact_id: contact_id
      )
    end
  end

  def sanitize_data(data)
    [*data].select &:present?
  end
  
  def set_options
    trust.notes = options[:notes]
    trust.trustee_ids = options[:trustee_ids]
    trust.agent_ids = options[:agent_ids]
    trust.successor_trustee_ids = options[:successor_trustee_ids]
    trust.name = options[:name]
  end

  attr_internal_accessor :trust, :options
end
