class DocumentPresenter < ApplicationPresenter
  attr_accessor :xml

  def self.from_document(document)
    new(xml: document.xml)
  end
end
