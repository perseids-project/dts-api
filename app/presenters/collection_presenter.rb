class CollectionPresenter < ApplicationPresenter
  attr_accessor :id, :total_items, :title, :member

  def self.from_params!(id:, nav:)
    raise BadRequestException unless %w[children parents].member?(nav)

    return default(nav: nav) if id == 'default'

    collection = Collection.find_by(urn: id)

    raise NotFoundException unless collection

    from_model(model: Collection.find_by(urn: id), nav: nav)
  end

  def self.from_model(model:, nav: 'children', nested: false)
    if nested
      members = nil
    elsif nav == 'children'
      members = model.children.map { |c| from_model(model: c, nested: true) }
    elsif nav == 'parents'
      parent = model.parent ? from_model(model: model.parent, nested: true) : default(nested: true)

      members = [parent]
    end

    new(
      id: model.urn,
      title: model.title,
      total_items: model.children.count,
      member: members,
    )
  end

  def self.default(nav: 'children', nested: false)
    children = Collection.where(parent_id: nil)

    if nested
      members = nil
    elsif nav == 'children'
      members = children.map { |c| from_model(model: c, nested: true) }
    elsif nav == 'parents'
      members = []
    end

    new(
      id: 'default',
      title: 'Root',
      total_items: children.count,
      member: members,
    )
  end

  def as_json(options = nil)
    json = {
      '@id': id,
      '@type': 'Collection',
      totalItems: total_items,
      title: title,
    }

    if member
      json[:'@context'] = {
        '@vocab': 'https://www.w3.org/ns/hydra/core#',
        dc: 'http://purl.org/dc/terms/',
        dts: 'https://w3id.org/dts/api#',
      }
      json[:member] = member.map(&:as_json)
    end

    json.as_json(options)
  end
end
