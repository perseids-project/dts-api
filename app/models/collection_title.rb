class CollectionTitle < ApplicationRecord
  belongs_to :collection

  validates :title, presence: true
  validates :language, presence: true, uniqueness: { scope: :collection_id }

  validate :language_code_must_exist

  before_save :canonicalize_language

  private

  def language_code_must_exist
    if language && !ISO_639.find(language)
      errors.add(:language, :invalid_language_code)
    end
  end

  def canonicalize_language
    iso = ISO_639.find(language)

    self.language = iso.alpha2.presence || iso.alpha3
  end
end
