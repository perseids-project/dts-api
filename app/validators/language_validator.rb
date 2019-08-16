class LanguageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !ISO_639.find(value)
      record.errors.add(attribute, options[:message] || :invalid_language_code)
    end
  end
end
