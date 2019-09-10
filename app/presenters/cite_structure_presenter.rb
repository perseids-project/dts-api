class CiteStructurePresenter < ApplicationPresenter
  attr_accessor :collection

  def initialize(collection)
    @collection = collection
  end

  def json
    {}.tap do |json|
      collection.cite_structure.each do |cite|
        nested_structure = { 'dts:citeType': cite }

        json[:'dts:citeStructure'] = [nested_structure]

        json = nested_structure
      end
    end
  end
end
