require 'iso-639'

module Utils
  class InvalidLanguageError < StandardError
    def initialize(language)
      super("Could not find language code: #{language}")
    end
  end

  def path(*dirs)
    Rails.root.join('texts', *dirs).to_s
  end

  def canonical_lang(language_string)
    iso = ISO_639.find(language_string)

    return iso.alpha2 unless iso.alpha2 == ''
    return iso.alpha3 unless iso.alpha3 == ''

    raise InvalidLanguageError, language_string
  end
end
