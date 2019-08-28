class PartialCollectionPresenter < ApplicationPresenter
  attr_accessor :id, :page_number, :last_page, :nav

  def json
    {
      '@id': path(page_number),
      '@type': 'PartialCollectionView',
      first: path(1),
      last: path(last_page),
    }.merge!(previous_next_links_json)
  end

  private

  def previous_next_links_json
    {}.tap do |json|
      if page_number > 1
        json[:previous] = path(page_number - 1)
      end

      if page_number < last_page
        json[:next] = path(page_number + 1)
      end
    end
  end

  def path(page)
    collections_path(id: id, page: page, nav: nav == 'parents' ? nav : nil)
  end
end
