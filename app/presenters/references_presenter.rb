class ReferencesPresenter < ApplicationPresenter
  attr_accessor :refs, :group_by

  def self.from_fragments(fragments, group_by:)
    new(
      refs: fragments.map(&:ref),
      group_by: group_by,
    )
  end

  def json
    group_by == 1 ? ungrouped_json : grouped_json
  end

  private

  def ungrouped_json
    refs.map { |ref| { ref: ref } }
  end

  def grouped_json
    refs.each_slice(group_by).map { |n| { start: n.first, end: n.last } }
  end
end
