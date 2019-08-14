class ApplicationController < ActionController::API
  rescue_from ApplicationException, with: :error

  def error(exception)
    error = ErrorPresenter.new(status: exception.status, title: exception.title)

    render json: error, status: error.status
  end
end
