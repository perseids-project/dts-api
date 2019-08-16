class CollectionPresenter < ApplicationPresenter
  attr_accessor :id, :total_items, :title, :member, :nested, :dublincore

  def self.from_params!(id:, nav:)
    raise BadRequestException unless %w[children parents].member?(nav)

    return default(nav: nav) if id == 'default'

    collection = Collection.find_by(urn: id)

    raise NotFoundException unless collection

    from_collection(Collection.find_by(urn: id), nav: nav)
  end

  def self.from_collection(collection, nav: 'children', nested: false)
    if nested
      members = nil
    elsif nav == 'children'
      members = collection.children.map { |c| from_collection(c, nested: true) }
    elsif nav == 'parents'
      members = [collection.parent ? from_collection(collection.parent, nested: true) : default(nested: true)]
    end

    new(
      id: collection.urn,
      title: collection.title,
      total_items: collection.children.count,
      member: members,
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

    json[:member] = member.map(&:as_json) if member.present?

    json.merge(dublincore.json)
  end
end
