class DocumentNavigationPresenter < ApplicationPresenter
  attr_accessor :document, :level

  def initialize(document, level:)
    @document = document
    @level = level || 1
  end

  def members
    document.fragments.where(level: level).order(:rank)
  end
end
