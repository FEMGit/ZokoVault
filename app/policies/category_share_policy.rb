class CategorySharePolicy < BasicPolicy
  def index?
    owned_or_shared?
  end
  
  def create?
    owned_or_shared?
  end

  protected 

  def owner_shared_category_with_user?
    shares = policy_share
    return false unless shares
    category_names = shares.select(&:shareable_type).select { |sh| sh.shareable.is_a? Category }.map(&:shareable).map(&:name)
    return false unless record.try(:category)
    return true if record.category.present? && (category_names.include? record.category.name)
    false
  end
end
