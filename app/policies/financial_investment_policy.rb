class FinancialInvestmentPolicy < CategorySharePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end
  
  def owner_shared_record_with_user?
    return false if record.empty_provider_id.nil?
    provider = FinancialProvider.find_by(id: record.empty_provider_id)
    Share.exists?(shareable: provider, contact: Contact.where("emailaddress ILIKE ?", user.email))
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user: user)
    end
  end
end
