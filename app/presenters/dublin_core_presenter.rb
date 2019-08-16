class DublinCorePresenter < ApplicationPresenter
  attr_accessor :titles, :language

  def self.from_collection(collection)
    titles = collection.collection_titles.map do |ct|
      TitlePresenter.from_collection_title(ct)
    end

    new(titles: titles, language: collection.language)
  end

  def self.default
    new(titles: [])
  end

  def json
    dublincore = {}

    dublincore[:'dc:title'] = titles if titles.present?
    dublincore[:'dc:language'] = language if language.present?

    dublincore.present? ? { 'dts:dublincore': dublincore } : {}
  end
end
