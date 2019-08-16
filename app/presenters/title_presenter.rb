class TitlePresenter < ApplicationPresenter
  attr_accessor :language, :title

  def self.from_collection_title(collection_title)
    new(language: collection_title.language, title: collection_title.title)
  end

  def json
    {
      '@language': language,
      '@value': title,
    }
  end
end
