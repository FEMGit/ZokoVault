class Document < ActiveRecord::Base
  white_list_categories = [Rails.application.config.x.FinancialInformationCategory,
                           Rails.application.config.x.WillsPoaCategory,
                           Rails.application.config.x.TrustsEntityCategory,
                           Rails.application.config.x.InsuranceCategory,
                           Rails.application.config.x.TaxCategory,
                           Rails.application.config.x.ProfileCategory,
                           Rails.application.config.x.TrustsEntitiesCategory,
                           Rails.application.config.x.FinalWishesCategory,
                           Rails.application.config.x.ContactCategory, "Select..."]

  belongs_to :user
  belongs_to :folder

  belongs_to :vendor

  scope :for_user, ->(user) {where(user: user)}

  scope :in_folder, ->(folder) {where(folder: folder)}
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :contacts, through: :shares

  validates :name, presence: { :message => "Required" }
  validates :url, presence: true

  accepts_nested_attributes_for :shares, reject_if: proc { |attributes| attributes[:contact_id].blank? }

  DOCUMENT_PREVIEW_FILES = %w(image pdf).freeze

  def self.previewed?(extension)
    DOCUMENT_PREVIEW_FILES.any? { |x| extension.include?(x) }
  end

  def self.image?(extension)
    %w(image).any? { |x| extension.include?(x) }
  end

  def self.pdf?(extension)
    extension.include?('pdf')
  end

  validates :category, inclusion: { in: white_list_categories, allow_blank: true }

  validates_length_of :name, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :group, :maximum => ApplicationController.helpers.get_max_length(:default)
  validates_length_of :description, :maximum => ApplicationController.helpers.get_max_length(:notes)

  before_validation :build_shares

  def contact_ids
    @contact_ids || shares.map(&:contact_id)
  end

  attr_writer :contact_ids

  def to_param
    uuid
  end

  private

  def build_shares
    shares.clear
    contact_ids.select(&:present?).each do |contact_id|
      shares.build(user_id: user_id, contact_id: contact_id)
    end
  end

end
