module EntitiesHelper
  def entity_present?(entity)
    entity.partners.any? || entity.agents.any? || entity.notes.present? ||
      category_subcategory_shares(entity, entity.user).present?
  end
end