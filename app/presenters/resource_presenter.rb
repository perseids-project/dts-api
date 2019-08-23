class ResourcePresenter < ApplicationPresenter
  attr_accessor :id, :title, :description, :passage, :member, :references, :cite_depth, :cite_structure, :nested

  def self.from_document(document, nav: 'children', nested: false)
    if !nested && nav == 'parents'
      members = [CollectionPresenter.from_collection(document.collection)]
    else
      members = nil
    end

    new(
      id: document.urn,
      title: document.title,
      description: document.description,
      member: members,
      nested: nested,
    )
  end

  def json
    json = {
      '@id': id,
      '@type': 'Resource',
      title: title,
      description: description,
      totalItems: 0,
    }

    unless nested
      json[:'@context'] = {
        '@vocab': 'https://www.w3.org/ns/hydra/core#',
        dc: 'http://purl.org/dc/terms/',
        dts: 'https://w3id.org/dts/api#',
      }
    end

    json[:member] = member if member.present?

    json
  end
end
