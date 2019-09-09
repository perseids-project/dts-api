class DocumentsController < ApplicationController
  include ProcessFragments

  def dts
    raise NotFoundException unless document
    raise NotFoundException if fragment_not_found?
    raise BadRequestException unless presenter.valid?

    headers['Link'] = presenter.link_header
    render xml: presenter
  end

  private

  def error_format
    :xml
  end

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
    DocumentPresenter.from_fragment(fragment, start: start, stop: stop)
  end

  def start_stop_presenter
    DocumentPresenter.from_start_and_stop(start_fragment, stop_fragment)
  end

  def document_presenter
    DocumentPresenter.from_document(document)
  end
end
