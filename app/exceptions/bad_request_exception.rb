class BadRequestException < ApplicationException
  def status
    400
  end
end
