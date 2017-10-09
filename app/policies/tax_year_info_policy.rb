class TaxYearInfoPolicy < CategorySharePolicy
  def owner_shared_record_with_user?
    shares = policy_share
    return false unless shares
    tax_shared_ids = shares.select { |sh| sh.shareable.is_a? Tax }.map(&:shareable_id)
    (record.taxes.map(&:id) & tax_shared_ids).any?
  end
end
