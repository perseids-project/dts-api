class DocumentsController < ApplicationController
  def dts
    raise BadRequestException if id.blank?
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
    params[:id]
  end
end
