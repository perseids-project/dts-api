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
    return @presenter if @presenter

    if ref
      @presenter = fragment_presenter
    elsif start || stop
      @presenter = start_stop_presenter
    else
      @presenter = document_presenter
    end
  end

  def fragment_presenter
    NavigationPresenter.from_fragment(fragment, ref: ref, start: start, stop: stop, level: level, group_by: group_by)
  end

  def start_stop_presenter
    NavigationPresenter.from_start_and_stop(start_fragment, stop_fragment, level: level, group_by: group_by)
  end

  def document_presenter
    NavigationPresenter.from_document(document, level: level, group_by: group_by)
  end

  def level
    params[:level].presence&.to_i
  end

  def group_by
    params[:groupBy].presence&.to_i || 1
  end
end
