class DublinCoreItemPresenter < ApplicationPresenter
  attr_accessor :language, :value

  def self.from_collection_title(collection_title)
    new(language: collection_title.language, value: collection_title.title)
  end

  def self.from_collection_description(collection_description)
    new(language: collection_description.language, value: collection_description.description)
  end

  def json
    {
      '@language': language,
      '@value': value,
    }
  end
end
