class Fragment < ApplicationRecord
  belongs_to :document
  belongs_to :parent, class_name: 'Fragment', optional: true

  has_many :children, class_name: 'Fragment', dependent: :destroy, foreign_key: :parent_id, inverse_of: :parent

  validates :ref, presence: true, uniqueness: { scope: :document_id }
  validates :xml, presence: true
  validates :level, presence: true, numericality: { only_integer: true }
  validates :rank, presence: true, numericality: { only_integer: true }, uniqueness: { scope: :document_id }

  def descendents(level)
    from_clause = Fragment.sanitize_sql_array([descendents_sql, { id: id, level: level }])

    Fragment.select('fragments.*').where('fragments.id = descendents.id').from(from_clause)
  end

  private

  def descendents_sql
    %(
      (
        WITH RECURSIVE parents AS (
          SELECT * FROM fragments WHERE id = :id
          UNION ALL
            SELECT f.* FROM fragments f
            INNER JOIN parents p ON p.id = f.parent_id
        ) SELECT * FROM parents WHERE level = :level
      ) AS descendents, fragments
    )
  end
end
