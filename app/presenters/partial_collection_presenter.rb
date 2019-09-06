class PartialCollectionPresenter < ApplicationPresenter
  attr_accessor :id, :page, :last_page, :nav

  def json
    {
      '@id': path(page),
      '@type': 'PartialCollectionView',
      first: path(1),
      last: path(last_page),
    }.merge!(previous_next_links_json)
  end

  private

  def previous_next_links_json
    {}.tap do |json|
      if page > 1
        json[:previous] = path(page - 1)
      end

      if page < last_page
        json[:next] = path(page + 1)
      end
    end
  end

  def path(page)
    collections_path(id: id, page: page, nav: nav == 'parents' ? nav : nil)
  end
end
