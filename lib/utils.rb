require 'iso-639'

module Utils
  TEXT_PATH = 'texts'.freeze

  def path(*dirs)
    Rails.root.join(TEXT_PATH, *dirs).to_s
  end
end
