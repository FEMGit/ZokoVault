ShareableCategory = Struct.new(:current_user, :id, :share_with_contact_ids) do

  def category
    @category ||= Category.find(id)
  end

  def execute
    prepare_shares
    share_with_contact_ids.select(&:present?).each do |contact_id|
      current_user.shares.create(contact_id: contact_id, shareable: category)
    end
    self
  end
  
  private
  
  def prepare_shares
    category_shares = Share.find(current_user.shares.where(shareable: category).map(&:id))
    share_with_contact_ids.select!(&:present?).map!(&:to_i)
    left_shares = category_shares.map(&:contact_id) & share_with_contact_ids
    category_shares.each { |share| (!left_shares.include? share.contact_id) && share.delete }
    share_with_contact_ids.delete_if { |x| category_shares.map(&:contact_id).include? x }
  end
end
