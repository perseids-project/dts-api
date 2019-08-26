class DublinCorePresenter < ApplicationPresenter
  attr_accessor :titles, :descriptions, :language

  def self.from_collection(collection)
    titles = collection.collection_titles.order(:id).map do |ct|
      DublinCoreItemPresenter.from_collection_title(ct)
    end

    descriptions = collection.collection_descriptions.order(:id).map do |cd|
      DublinCoreItemPresenter.from_collection_description(cd)
    end

    new(titles: titles, descriptions: descriptions, language: collection.language)
  end

  def self.default
    new(titles: [])
  end

  def json
    dublincore = {}

    dublincore[:'dc:title'] = titles if titles.present?
    dublincore[:'dc:description'] = descriptions if descriptions.present?
    dublincore[:'dc:language'] = language if language.present?

    dublincore.present? ? { 'dts:dublincore': dublincore } : {}
  end
end
