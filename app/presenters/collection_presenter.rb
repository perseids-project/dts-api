class CollectionPresenter < ApplicationPresenter
  attr_accessor :id, :total_items, :title, :member

  def self.from_params!(id:, nav:)
    raise BadRequestException unless %w[children parents].member?(nav)

    return default(nav: nav) if id == 'default'

    collection = Collection.find_by(urn: id)

    raise NotFoundException unless collection

    from_model(model: Collection.find_by(urn: id), nav: nav)
  end

  def self.from_model(model:, nav: 'children')
    if nav == 'children'
      members = model.children.map { |c| from_model(model: c) }
    elsif nav == 'parents'
      parent = model.parent ? from_model(model: model.parent) : default

      members = [parent]
    end

    new(
      id: model.urn,
      title: model.title,
      total_items: model.children.count,
      member: members,
    )
  end

  def self.default(nav: 'children')
    children = Collection.where(parent_id: nil)

    new(
      id: 'default',
      title: 'Root',
      total_items: children.count,
      member: nav == 'children' ? children.map { |c| from_model(model: c) } : [],
    )
  end

  def as_json(options = nil)
    nested = options&.key?(:nested) ? options[:nested] : false

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
      json[:member] = member.map { |c| c.as_json(nested: true) }
    end

    json.as_json(options)
  end
end
