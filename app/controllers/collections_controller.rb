class CollectionsController < ApplicationController
  def dts
    raise NotFoundException unless collection
    raise BadRequestException unless presenter.valid?

    render json: presenter
  end

  private

  def presenter
    @presenter ||= CollectionPresenter.from_collection(collection, nav: nav)
  end

  def collection
    @collection ||= Collection.find_by(urn: id)
  end

  def id
    params[:id].presence || 'default'
  end

  def nav
    params[:nav].presence || 'children'
  end
end
