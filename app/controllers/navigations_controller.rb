class NavigationsController < ApplicationController
  include ProcessFragments

  def dts
    raise NotFoundException unless document
    raise NotFoundException if fragment_not_found?
    raise BadRequestException unless presenter.valid?

    render json: presenter
  end

  private

  def presenter
    @presenter ||= NavigationPresenter.new(
      document,
      fragment,
      start_fragment,
      stop_fragment,
      level: level,
      group_by: group_by,
    )
  end

  def level
    params[:level].presence&.to_i
  end

  def group_by
    params[:groupBy].presence&.to_i || 1
  end
end
