class ErrorPresenter < ApplicationPresenter
  attr_accessor :status, :title

  def as_json(options = nil)
    {
      '@context': 'http://www.w3.org/ns/hydra/context.jsonld',
      '@type': 'Error',
      statusCode: status,
      title: title,
    }.as_json(options)
  end
end
