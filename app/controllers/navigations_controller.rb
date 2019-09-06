class NavigationsController < ApplicationController
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
    NavigationPresenter.from_fragment(fragment, ref: ref, level: level, start: start, stop: stop, group_by: group_by)
  end

  def start_stop_presenter
    NavigationPresenter.from_start_and_stop(document, start_fragment, stop_fragment, level: level, group_by: group_by)
  end

  def document_presenter
    NavigationPresenter.from_document(document, level: level, group_by: group_by)
  end

  def document
    @document ||= Document.find_by(urn: id)
  end

  def fragment
    @fragment ||= Fragment.find_by(document: document, ref: ref)
  end

  def start_fragment
    @start_fragment ||= Fragment.find_by(document: document, ref: start)
  end

  def stop_fragment
    @stop_fragment ||= Fragment.find_by(document: document, ref: stop)
  end

  def fragment_not_found?
    (ref && !fragment) || (start && !start_fragment) || (stop && !stop_fragment)
  end

  def id
    params[:id].presence
  end

  def level
    params[:level].presence&.to_i
  end

  def start
    params[:start].presence
  end

  def stop
    params[:end].presence
  end

  def ref
    params[:ref].presence
  end

  def group_by
    params[:groupBy].presence&.to_i || 1
  end

  def exclude
    params[:exclude].presence
  end
end
