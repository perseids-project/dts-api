class ApplicationController < ActionController::API
  rescue_from ApplicationException, with: :error

  private

  def error(exception)
    error = ErrorPresenter.new(status: exception.status, title: exception.title)

    render error_format => error, status: error.status
  end

  def error_format
    :json
  end
end
