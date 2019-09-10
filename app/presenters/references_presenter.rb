class ReferencesPresenter < ApplicationPresenter
  attr_accessor :fragments, :group_by

  def initialize(fragments, group_by:)
    @fragments = fragments
    @group_by = group_by
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

  def refs
    @refs ||= fragments.map(&:ref)
  end
end
