class CollectionsController < ApplicationController
  def dts
    render json: CollectionPresenter.from_params!(**collection_params)
  end

  private

  def collection_params
    {
      id: params[:id] || 'default',
      nav: params[:nav] || 'children',
    }
  end
end
