class DocumentsController < ApplicationController
  include ProcessFragments

  def dts
    check_for_exceptions

    headers['Link'] = presenter.link_header
    if format == :epub
      render_epub
    else
      render format => presenter
    end
  end

  private

  def format
    @format ||= {
      'epub' => :epub,
    }[params[:format]] || :xml
  end

  def error_format
    format
  end

  def presenter
    @presenter ||= DocumentPresenter.new(document, fragment, start_fragment, stop_fragment)
  end

  # TODO: get rid of this method and move back into #dts
  def check_for_exceptions
    raise NotFoundException unless document
    raise NotFoundException if fragment_not_found?
    raise BadRequestException unless presenter.valid?
  end

  # TODO: use a renderer for this
  def render_epub
    send_data presenter.to_epub, content_type: 'application/epub+zip', filename: 'book.epub'
  end
end
