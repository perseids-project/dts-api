class ApplicationPresenter
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  class << self
    include Rails.application.routes.url_helpers
  end

  def valid?
    true
  end

  def as_json(options = nil)
    json.as_json(options)
  end

  def to_xml(_options = {})
    xml
  end
end
