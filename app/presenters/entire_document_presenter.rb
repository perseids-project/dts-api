require 'gepub' # TODO
require 'mondrian_book_cover'

class EntireDocumentPresenter < ApplicationPresenter
  attr_accessor :document

  delegate :xml, to: :document

  def initialize(document)
    @document = document
  end

  def links
    []
  end

  # TODO: move this logic somewhere else - and support fragments
  # TODO: parse XML to generate some of this info
  def epub
    book = GEPUB::Book.new
    book.primary_identifier(epub_url, 'BookID', 'URL')
    book.language = collection.language

    book.add_title(
      collection.title,
      title_type: GEPUB::TITLE_TYPE::MAIN,
      lang: collection.language,
      file_as: collection.title,
      display_seq: 1,
    )

    book.add_item('img/cover.svg', content: StringIO.new(cover_svg)).cover_image

    fragments = document.fragments.where(level: 1).order(:rank)

    book.ordered do
      book.add_item('text/cover.xhtml', StringIO.new(cover)).landmark(type: 'cover', title: 'Cover')
      book.add_item('text/contents.xhtml', StringIO.new(contents(fragments.size))).landmark(type: 'toc', title: 'Table of Contents')

      fragments.each do |fragment|
        html = book_xml(Nokogiri::XML(fragment.xml).xpath('//dts:fragment', dts: 'https://w3id.org/dts/api#').first.inner_html.strip, fragment.rank)

        book
          .add_item("text/book#{fragment.rank + 1}.xhtml")
          .add_content(StringIO.new(html))
          .landmark(type: 'bodymatter', title: "Book #{fragment.rank + 1}")
          .toc_text("Book #{fragment.rank + 1}")
      end
    end

    book.generate_epub_stream
  end

  private

  def epub_url
    # TODO: use documents_url and set host
    documents_path(id: document.urn, format: 'epub')
  end

  def collection
    document.collection
  end

  # TODO: move logic
  # TODO: use author
  def cover_svg
    @cover_svg ||= MondrianBookCover.cover(collection.title, '')
  end

  def cover
    <<~COVER
      <?xml version="1.0"?>
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <title>Cover</title>
          <style type="text/css">
             div { text-align: center }
             img { max-width: 100%; }
          </style>
        </head>
        <body>
          <div>
            <img src="../img/cover.svg" alt="Cover" />
          </div>
        </body>
      </html>
    COVER
  end

  def contents(levels)
    <<~CONTENTS
      <?xml version='1.0' encoding='utf-8'?>
      <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
      <html xmlns="http://www.w3.org/1999/xhtml">
        <body>
          <h2>CONTENTS</h2>
          <br />
          <ul>
            #{(1..levels).to_a.map{ |l| "<li><a href=\"book#{l}.xhtml\">Book #{l}</a></li>" }.join("\n")}
          </ul>
        </body>
      </html>
    CONTENTS
  end

  def book_xml(book_text, rank)
    <<~XML
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <title>Title</title>
        </head>
        <body>
          <h2>Book #{rank + 1}</h2>
          <br />
          #{book_text}
        </body>
      </html>
    XML
  end
end
