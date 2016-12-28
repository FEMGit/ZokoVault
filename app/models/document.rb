class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :folder
  
  belongs_to :vendor

  scope :for_user, ->(user) {where(user: user)}
  scope :wills, -> {where(category: "Wills - Trusts - Legal")}

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
end
