class DocumentPresenter < ApplicationPresenter
  attr_accessor :presenter, :document
  delegate :valid?, :links, :xml, to: :presenter
  delegate :urn, :collection, to: :document
  delegate :urn, :collection, to: :collection, prefix: :collection

  def initialize(document, fragment, start, stop)
    @document = document

    if invalid_combination?(fragment, start, stop)
      @presenter = InvalidPresenter.new
    elsif fragment
      @presenter = FragmentPresenter.new(document, fragment)
    elsif start
      @presenter = StartStopFragmentPresenter.new(document, start, stop)
    else
      @presenter = EntireDocumentPresenter.new(document)
    end
  end

  def link_header
    (links + [
      "<#{navigation_path(id: urn)}>; rel=\”contents\”",
      "<#{collections_path(id: collection_urn)}>; rel=\”collection\”",
    ]).join(', ')
  end

  private

  def invalid_combination?(fragment, start, stop)
    (fragment && (start || stop)) || invalid_start_stop_combination?(start, stop)
  end

  def invalid_start_stop_combination?(start, stop)
    start && !stop || stop && !start
  end
end
