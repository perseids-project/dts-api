class NavigationPresenter < ApplicationPresenter
  attr_accessor :presenter, :document, :fragment, :start, :stop, :group_by

  delegate :valid?, :members, :level, to: :presenter
  delegate :urn, :cite_depth, to: :document

  def initialize(document, fragment, start, stop, level:, group_by:)
    @document = document
    @fragment = fragment
    @start = start
    @stop = stop
    @group_by = group_by

    if invalid_combination?(fragment, start, stop)
      @presenter = InvalidPresenter.new
    elsif fragment
      @presenter = FragmentNavigationPresenter.new(document, fragment, level: level)
    elsif start
      @presenter = StartStopNavigationPresenter.new(document, start, stop, level: level)
    else
      @presenter = DocumentNavigationPresenter.new(document, level: level)
    end
  end

  def json
    {
      '@context': {
        '@vocab': 'https://www.w3.org/ns/hydra/core#',
        dc: 'http://purl.org/dc/terms/',
        dts: 'https://w3id.org/dts/api#',
      },
      '@id': navigation_id,
      'dts:citeDepth': cite_depth,
      'dts:level': level,
      'dts:passage': passage_path,
    }.merge(member_json)
  end

  private

  def invalid_combination?(fragment, start, stop)
    (fragment && (start || stop)) || invalid_start_stop_combination?(start, stop)
  end

  def invalid_start_stop_combination?(start, stop)
    (start && !stop) || (stop && !start)
  end

  def member_json
    references = members

    return {} if references.empty?

    { member: ReferencesPresenter.new(references, group_by: group_by) }
  end

  def navigation_id
    args = {
      id: urn,
      level: level,
      start: start&.ref,
      end: stop&.ref,
      ref: fragment&.ref,
      groupBy: group_by,
    }.compact

    navigation_path(args)
  end

  def passage_path
    "#{documents_path(id: urn)}{&ref}{&start}{&end}"
  end
end
