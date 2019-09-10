class CollectionsController < ApplicationController
  def dts
    raise NotFoundException unless collection
    raise BadRequestException unless presenter.valid?

    render json: presenter
  end

  private

  def presenter
    @presenter ||= CollectionPresenter.new(collection, nav: nav, page: page)
  end

  def collection
    @collection ||= Collection.find_by(urn: id)
  end

  def page
    params[:page].presence&.to_i
  end

  def id
    params[:id].presence || 'default'
  end

  def nav
    params[:nav].presence || 'children'
  end
end
