class PagesPresenter < ApplicationPresenter
  def json
    {
      '@context': 'dts/EntryPoint.jsonld',
      '@id': root_path,
      '@type': 'EntryPoint',
      collections: collections_path,
      documents: documents_path,
      navigation: navigation_path,
    }
  end
end
