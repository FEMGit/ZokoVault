ShareableCategory = Struct.new(:current_user, :id, :share_with_contact_ids) do

  def category
    @category ||= Category.find(id)
  end

  def execute
    share_with_contact_ids.select(&:present?).each do |contact_id|
      current_user.shares.create(contact_id: contact_id, shareable: category)
    end
    self
  end
end

