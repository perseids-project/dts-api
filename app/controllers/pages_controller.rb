class PagesController < ApplicationController
  def dts
    render json: PagesPresenter.new
  end
end
