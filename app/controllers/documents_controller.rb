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
    @presenter ||= DocumentPresenter.new(document, fragment, start_fragment, stop_fragment)
  end
end
