RSpec::Matchers.define :beautify_xml_of do |attribute|
  match do |subject|
    subject.assign_attributes(attribute => '<test></test>')
    expect(subject.read_attribute(attribute)).to eq(%(<?xml version="1.0"?>\n<test/>\n))
  end
end
