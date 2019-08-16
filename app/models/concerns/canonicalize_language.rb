module CanonicalizeLanguage
  extend ActiveSupport::Concern

  module ClassMethods
    def canonicalize(*attributes)
      attributes.each do |attribute|
        define_method("#{attribute}=") do |language|
          iso = ISO_639.find(language)
          code = iso ? (iso.alpha2.presence || iso.alpha3) : language

          self[attribute] = code
        end
      end
    end
  end
end
