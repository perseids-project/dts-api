class EntireDocumentPresenter < ApplicationPresenter
  attr_accessor :document
  delegate :xml, to: :document

  def initialize(document)
    @document = document
  end

  def links
    []
  end
end
