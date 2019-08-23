class CollectionPresenter < ApplicationPresenter
  attr_accessor :id, :total_items, :title, :member, :nested, :dublincore

  def self.from_collection(collection, nav: 'children', nested: false)
    new(
      id: collection.urn,
      title: collection.title,
      total_items: collection.total_items,
      member: nested ? nil : members(collection, nav),
      nested: nested,
      dublincore: DublinCorePresenter.from_collection(collection),
    )
  end

  def self.default(nav: 'children', nested: false)
    children = Collection.where(parent_id: nil)

    if nested || nav == 'parents'
      members = nil
    elsif nav == 'children'
      members = children.map { |c| from_collection(c, nested: true) }
    end

    new(
      id: 'default',
      title: 'Root',
      total_items: children.count,
      member: members,
      nested: nested,
      dublincore: DublinCorePresenter.default,
    )
  end

  def self.members(collection, nav)
    if nav == 'children'
      children = collection.children.order(:id).map { |c| from_collection(c, nested: true) }
      documents = collection.documents.order(:id).map { |d| ResourcePresenter.from_document(d, nested: true) }

      return children + documents
    end

    return [from_collection(collection.parent, nested: true)] if collection.parent

    [default(nested: true)]
  end

  private_class_method :members

  def json
    json = {
      '@id': id,
      '@type': 'Collection',
      totalItems: total_items,
      title: title,
    }

    unless nested
      json[:'@context'] = {
        '@vocab': 'https://www.w3.org/ns/hydra/core#',
        dc: 'http://purl.org/dc/terms/',
        dts: 'https://w3id.org/dts/api#',
      }
    end

    json[:member] = member if member.present?

    json.merge(dublincore.json)
  end
end
