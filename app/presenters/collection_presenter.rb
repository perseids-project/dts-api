class CollectionPresenter < ApplicationPresenter
  attr_accessor :cite_depth, :cite_structure, :description, :dublincore, :id, :last_page, :member_proc,
    :nav, :nested, :page, :title, :total, :type

  def self.from_collection(collection, nav: 'children', page: nil, nested: false)
    new(
      cite_depth: collection.cite_depth,
      cite_structure: CiteStructurePresenter.from_collection(collection),
      description: collection.description,
      dublincore: DublinCorePresenter.from_collection(collection),
      id: collection.urn,
      last_page: last_page(collection, nav, page),
      member_proc: member_proc(collection, nav, page),
      nav: nav,
      nested: nested,
      page: page,
      title: collection.title,
      total: collection.children_count,
      type: collection.display_type.titleize,
    )
  end

  def self.member_proc(collection, nav, page)
    lambda do
      if nav == 'parents' && collection.parent
        [from_collection(collection.parent, nested: true)]
      elsif page && nav == 'children'
        collection.paginated_children(page).map { |c| from_collection(c, nested: true) }
      elsif nav == 'children'
        collection.children.order(:id).map { |c| from_collection(c, nested: true) }
      else
        []
      end
    end
  end

  def self.last_page(collection, nav, page)
    if !page
      nil
    elsif nav == 'parents' && collection.parent
      1
    elsif nav == 'children'
      collection.last_page
    else
      0
    end
  end

  private_class_method :member_proc, :last_page

  def valid?
    return false unless %w[children parents].member?(nav)
    return false if page && !page_valid?

    true
  end

  def json
    {
      '@id': id,
      '@type': type,
      totalItems: total,
      title: title,
    }.merge(optional_json, member_json, context_json, resource_json, view_json, dublincore.json)
  end

  private

  def page_valid?
    page >= 1 && page <= last_page
  end

  def optional_json
    {}.tap do |json|
      json[:description] = description if description.present?
    end
  end

  def member_json
    return {} if nested

    member = member_proc.call

    return {} if member.empty?

    { member: member }
  end

  def context_json
    return {} if nested

    {
      '@context': {
        '@vocab': 'https://www.w3.org/ns/hydra/core#',
        dc: 'http://purl.org/dc/terms/',
        dts: 'https://w3id.org/dts/api#',
      },
    }
  end

  def resource_json
    return {} unless type == 'Resource'

    {
      'dts:passage': documents_path(id: id),
      'dts:references': navigation_path(id: id),
      'dts:download': documents_path(id: id),
      'dts:citeDepth': cite_depth,
    }.merge!(cite_structure.json)
  end

  def view_json
    return {} unless page

    { view: PartialCollectionPresenter.new(id: id, page: page, last_page: last_page, nav: nav) }
  end
end
