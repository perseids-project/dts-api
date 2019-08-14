class NotFoundException < ApplicationException
  def status
    404
  end
end
