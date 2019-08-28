class CollectionPresenter < ApplicationPresenter
  attr_accessor :id, :type, :total, :title, :description, :member_proc, :nested, :nav, :page, :last_page, :dublincore

  def self.from_collection(collection, nav: 'children', page: nil, nested: false)
    new(
      id: collection.urn,
      type: collection.display_type.titleize,
      title: collection.title,
      description: collection.description,
      total: collection.children_count,
      member_proc: member_proc(collection, nav, page),
      nested: nested,
      nav: nav,
      page: page,
      last_page: last_page(collection, nav, page),
      dublincore: DublinCorePresenter.from_collection(collection),
    )
  end

  def self.member_proc(collection, nav, page)
    lambda do
      if nav == 'parents' && collection.parent
        [from_collection(collection.parent, nested: true)]
      elsif page && nav == 'children'
        collection.paginated_children(page.to_i).map { |c| from_collection(c, nested: true) }
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
    page =~ /\A\d+\z/ && page_number >= 1 && page_number <= last_page
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
    }
  end

  def view_json
    return {} unless page

    { view: PartialCollectionPresenter.new(id: id, page_number: page_number, last_page: last_page, nav: nav) }
  end

  def page_number
    @page_number ||= page.to_i
  end
end
