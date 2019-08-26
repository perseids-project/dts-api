class CollectionPresenter < ApplicationPresenter
  attr_accessor :id, :type, :total_items, :title, :description, :member, :nested, :nav, :dublincore

  def self.from_collection(collection, nav: 'children', nested: false)
    new(
      id: collection.urn,
      type: collection.display_type.titleize,
      title: collection.title,
      description: collection.description,
      total_items: collection.children_count,
      member: nested ? nil : members(collection, nav),
      nested: nested,
      nav: nav,
      dublincore: DublinCorePresenter.from_collection(collection),
    )
  end

  def self.members(collection, nav)
    if nav == 'parents' && collection.parent
      [from_collection(collection.parent, nested: true)]
    elsif nav == 'children'
      collection.children.order(:id).map { |c| from_collection(c, nested: true) }
    end
  end

  private_class_method :members

  def valid?
    %w[children parents].member?(nav)
  end

  def json
    json = {
      '@id': id,
      '@type': type,
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

    json[:description] = description if description.present?
    json[:member] = member if member.present?

    json.merge(dublincore.json)
  end
end
