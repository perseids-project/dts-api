class FragmentPresenter < ApplicationPresenter
  attr_accessor :document, :fragment

  delegate :xml, to: :fragment
  delegate :urn, to: :document

  def initialize(document, fragment)
    @document = document
    @fragment = fragment
  end

  def links
    {
      prev: fragment.previous_fragment,
      next: fragment.next_fragment,
      up: fragment.parent,
      first: fragment.first_fragment,
      last: fragment.last_fragment,
    }.map { |name, fragment| link(name, fragment) }.compact
  end

  private

  def link(name, fragment)
    return nil unless fragment

    "<#{documents_path(id: urn, ref: fragment.ref)}>; rel=\"#{name}\""
  end
end
