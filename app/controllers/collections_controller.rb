class CollectionsController < ApplicationController
  def dts
    raise BadRequestException unless %w[children parents].member?(nav)
    raise NotFoundException unless presenter

    render json: presenter
  end

  private

  def presenter
    if id == 'default'
      @presenter ||= default
    elsif collection
      @presenter ||= CollectionPresenter.from_collection(collection, nav: nav)
    elsif document
      @presenter ||= ResourcePresenter.from_document(document, nav: nav)
    end
  end

  def collection
    @collection ||= Collection.find_by(urn: id)
  end

  def document
    @document ||= Document.find_by(urn: id)
  end

  def default
    @default ||= CollectionPresenter.default(nav: nav)
  end

  def id
    params[:id].presence || 'default'
  end

  def nav
    params[:nav].presence || 'children'
  end
end
