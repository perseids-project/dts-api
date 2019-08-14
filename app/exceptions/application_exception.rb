class ApplicationException < StandardError
  def initialize(status: 500, title: nil)
    @status = status
    @title = title
  end

  attr_reader :status

  def title
    @title ||= Rack::Utils::HTTP_STATUS_CODES[status]
  end
end
