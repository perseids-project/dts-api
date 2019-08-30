class CiteStructurePresenter < ApplicationPresenter
  attr_accessor :cite_structure

  def self.from_collection(collection)
    new(cite_structure: collection.cite_structure)
  end

  def json
    {}.tap do |json|
      cite_structure.each do |cite|
        nested_structure = { 'dts:citeType': cite }

        json[:'dts:citeStructure'] = [nested_structure]

        json = nested_structure
      end
    end
  end
end
