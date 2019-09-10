class CollectionMetadataPresenter < ApplicationPresenter
  attr_accessor :collection
  delegate :cite_depth, to: :collection

  def initialize(collection)
    @collection = collection
  end

  def json
    return {} unless collection.resource?

    {
      'dts:passage': documents_path(id: id),
      'dts:references': navigation_path(id: id),
      'dts:download': documents_path(id: id),
      'dts:citeDepth': cite_depth,
    }.merge!(cite_structure_json)
  end

  private

  def id
    @id ||= collection.urn
  end

  def cite_structure_json
    CiteStructurePresenter.new(collection).json
  end
end
