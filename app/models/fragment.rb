class Fragment < ApplicationRecord
  belongs_to :document
  belongs_to :parent, class_name: 'Fragment', optional: true

  has_many :children, class_name: 'Fragment', dependent: :destroy, foreign_key: :parent_id, inverse_of: :parent

  validates :ref, presence: true, uniqueness: { scope: :document_id }
  validates :xml, presence: true
  validates :level, presence: true, numericality: { only_integer: true }
  validates :rank, presence: true, numericality: { only_integer: true }, uniqueness: { scope: :document_id }
  validates :descendent_rank, presence: true, numericality: { only_integer: true }

  def previous_fragment
    Fragment.find_by(document: document, parent: parent, level: level, rank: rank - 1)
  end

  def previous_range(stop_fragment)
    range = siblings.select { |fragment| fragment.rank < rank }.last(steps(stop_fragment))

    range.empty? ? [] : [range.first, range.last]
  end

  def next_fragment
    Fragment.find_by(document: document, parent: parent, level: level, rank: rank + 1)
  end

  def next_range(stop_fragment)
    range = siblings.select { |fragment| fragment.rank > stop_fragment.rank }.first(steps(stop_fragment))

    range.empty? ? [] : [range.first, range.last]
  end

  def first_fragment
    Fragment.where(document: document, parent: parent, level: level).order(:rank).first
  end

  def first_range(stop_fragment)
    range = siblings.first(steps(stop_fragment))

    [range.first, range.last]
  end

  def last_fragment
    Fragment.where(document: document, parent: parent, level: level).order(:rank).last
  end

  def last_range(stop_fragment)
    range = siblings.last(steps(stop_fragment))

    [range.first, range.last]
  end

  private

  def steps(stop_fragment)
    siblings.count { |fragment| fragment.rank >= rank && fragment.rank <= stop_fragment.descendent_rank }
  end

  def siblings
    @siblings ||= Fragment.where(document: document, level: level).order(:rank)
  end
end
