class DublinCorePresenter < ApplicationPresenter
  attr_accessor :collection
  delegate :language, to: :collection

  def initialize(collection)
    @collection = collection
  end

  def json
    dublincore = {}

    dublincore[:'dc:title'] = titles if titles.present?
    dublincore[:'dc:description'] = descriptions if descriptions.present?
    dublincore[:'dc:language'] = language if language.present?

    dublincore.present? ? { 'dts:dublincore': dublincore } : {}
  end

  private

  def titles
    @titles ||= collection.collection_titles.order(:id).map do |ct|
      DublinCoreItemPresenter.from_collection_title(ct)
    end
  end

  def descriptions
    @descriptions ||= collection.collection_descriptions.order(:id).map do |cd|
      DublinCoreItemPresenter.from_collection_description(cd)
    end
  end
end
