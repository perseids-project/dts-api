class DocumentsController < ApplicationController
  def dts
    raise BadRequestException unless id
    raise NotFoundException unless document

    render xml: presenter
  end

  private

  def error_format
    :xml
  end

  def presenter
    @presenter ||= DocumentPresenter.from_document(document)
  end

  def document
    @document ||= Document.find_by(urn: id)
  end

  def id
    params[:id].presence
  end
end
