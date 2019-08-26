class ApplicationPresenter
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  def valid?
    true
  end

  def as_json(options = nil)
    json.as_json(options)
  end
end
