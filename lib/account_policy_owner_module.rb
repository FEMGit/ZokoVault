module AccountPolicyOwnerModule
  def self.included(base)
    base.before_filter :set_account_owners, only: [:new, :edit]
  end

  def set_account_owners
    trusts = CardDocument.for_user(resource_owner).trusts.collect { |x| [x.id.to_s + '_owner', x.name, class: "owner-item"] }
    entities = CardDocument.for_user(resource_owner).entities.collect { |x| [x.id.to_s + '_owner', x.name, class: "owner-item"] }
    contacts = @contacts.collect { |s| [s.id.to_s + '_contact', s.name, class: "contact-item"] }
    @account_owners = (trusts + entities + contacts).sort_by { |s| s.second.downcase }
  end

  module_function :set_account_owners
end
