class FragmentNavigationPresenter < ApplicationPresenter
  attr_accessor :document, :fragment, :level

  def initialize(document, fragment, level:)
    @document = document
    @fragment = fragment
    @level = level || (fragment.level + 1)
  end

  def members
    document.fragments.where(rank: (fragment.rank..fragment.descendent_rank), level: level).order(:rank)
  end
end
