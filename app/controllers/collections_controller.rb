class CollectionsController < ApplicationController
  def dts
    raise NotFoundException unless presenter
    raise BadRequestException unless presenter.valid?

    render json: presenter
  end

  private

  def presenter
    return @presenter if instance_variable_defined?(:@presenter)

    if collection
      @presenter = CollectionPresenter.from_collection(collection, nav: nav)
    else
      @presenter = nil
    end
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
