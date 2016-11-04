class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :folder

  scope :for_user, ->(user) {where(user: user)}
  scope :wills, -> {where(category: "Wills - Trusts - Legal")}

  scope :in_folder, ->(folder) {where(folder: folder)}
  has_many :shares, dependent: :destroy, foreign_key: "document_id"
  has_many :contacts, through: :shares

  validates :name, presence: true
  validates :url, presence: true

  accepts_nested_attributes_for :shares, reject_if: proc { |attributes| attributes[:contact_id].blank? }

  DOCUMENT_PREVIEW_FILES = %w(image pdf).freeze
    
  def self.previewed?(extension)
    DOCUMENT_PREVIEW_FILES.any? { |x| extension.include?(x) }
  end
end
