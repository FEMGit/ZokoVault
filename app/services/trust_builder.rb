class TrustBuilder

  def initialize(options = {})
    self.trust = Trust.new(options.slice(:user_id, :document_id, :name))
    self.options = options
  end

  def build
    build_trustees

    sanitize_data(options[:agent_ids]).each do |contact_id|
      trust.vault_entry_contacts.build(
        active: true, type: :agent, contact_id: contact_id
      )
    end

    share_options = { document_id: trust.document_id, user_id: options[:user_id] }
    sanitize_data(options[:share_ids]).each do |contact_id|
      trust.shares.build(share_options.merge(contact_id: contact_id))
    end

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

  attr_internal_accessor :trust, :options
end
