class CollectionPresenter < ApplicationPresenter
  attr_accessor :collection, :nav, :page, :nested
  delegate :urn, :children, :description, :display_type, :parent, :title, :children_count, to: :collection

  def initialize(collection, nav: 'children', page: nil, nested: false)
    @collection = collection
    @nav = nav
    @page = page
    @nested = nested
  end

  def valid?
    return false unless parents? || children?
    return false if page && !page_valid?

    true
  end

  def json
    {
      '@id': urn,
      '@type': display_type.titleize,
      totalItems: total_items,
      title: title,
    }.merge(optional_json, member_json, context_json, resource_json, view_json, dublincore_json)
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

    member = members

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
    CollectionMetadataPresenter.new(collection).json
  end

  def view_json
    return {} unless page

    { view: PartialCollectionPresenter.new(id: urn, page: page, last_page: last_page, nav: nav) }
  end

  def dublincore_json
    DublinCorePresenter.new(collection).json
  end

  def members
    return @members if @members

    if parents?
      @members = parent_members
    elsif page
      @members = paginated_members
    else
      @members = child_members
    end
  end

  def parent_members
    parent ? [CollectionPresenter.new(parent, nav: nav, nested: true)] : []
  end

  def paginated_members
    members = collection.paginated_children(page).includes(:collection_titles, :collection_descriptions)

    members.map { |c| CollectionPresenter.new(c, nav: nav, nested: true) }
  end

  def child_members
    members = children.includes(:collection_titles, :collection_descriptions)

    members.map { |c| CollectionPresenter.new(c, nav: nav, nested: true) }
  end

  def last_page
    return @last_page if @last_page

    if !page
      @last_page = nil
    elsif parents? && parent
      @last_page = 1
    elsif children?
      @last_page = collection.last_page
    else
      @last_page = 0
    end
  end

  def total_items
    return children_count if children?
    return 1 if parent

    0
  end

  def parents?
    nav == 'parents'
  end

  def children?
    nav == 'children'
  end
end
