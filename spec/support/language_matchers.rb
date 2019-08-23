RSpec::Matchers.define :validate_language_of do |attribute|
  match do |subject|
    subject.assign_attributes(attribute => 'en')
    subject.valid?
    expect(subject.errors[attribute]).to_not include('is not a valid language code')

    subject.assign_attributes(attribute => '123')
    subject.valid?
    expect(subject.errors[attribute]).to include('is not a valid language code')
  end
end

RSpec::Matchers.define :canonicalize_language_of do |attribute|
  match do |subject|
    subject.assign_attributes(attribute => 'eng')
    expect(subject.read_attribute(attribute)).to eq('en')

    subject.assign_attributes(attribute => 'grc')
    expect(subject.read_attribute(attribute)).to eq('grc')
  end
end
