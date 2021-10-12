class Collection < ApplicationRecord
  include CanonicalizeLanguage

  belongs_to :parent, class_name: 'Collection', optional: true, counter_cache: :children_count

  has_many :children,
    -> { order(:id) },
    class_name: 'Collection',
    dependent: :destroy,
    foreign_key: :parent_id,
    inverse_of: :parent

  has_many :collection_descriptions, -> { order(:id) }, dependent: :destroy, inverse_of: :collection
  has_many :collection_titles, -> { order(:id) }, dependent: :destroy, inverse_of: :collection

  has_one :document, dependent: :destroy

  validates :urn, presence: true, uniqueness: true
  validates :title, presence: true
  validates :language, language: true

  validates :document, absence: true, if: :collection?

  validates :document, presence: true, if: :resource?

  enum display_type: [:collection, :resource]

  canonicalize :language

  def cite_depth
    cite_structure&.size
  end

  def last_page(page_size: 10)
    ((children_count - 1) / page_size) + 1
  end

  def paginated_children(page, page_size: 10)
    first = (page - 1) * page_size

    children.order(:id).offset(first).limit(page_size)
  end
end
