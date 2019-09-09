class NavigationPresenter < ApplicationPresenter
  attr_accessor :id, :cite_depth, :level, :start, :stop, :ref, :group_by, :member_proc

  def self.from_document(document, level:, group_by:)
    level ||= 1

    new(
      id: document.urn,
      cite_depth: document.cite_depth,
      level: level,
      group_by: group_by,
      member_proc: document_member_proc(document, level),
    )
  end

  def self.from_start_and_stop(start_fragment, stop_fragment, level:, group_by:)
    level ||= start_fragment.level
    document = start_fragment.document

    new(
      id: document.urn,
      cite_depth: document.cite_depth,
      level: level,
      start: start_fragment&.ref,
      stop: stop_fragment&.ref,
      group_by: group_by,
      member_proc: document_member_start_end_proc(level, start_fragment, stop_fragment),
    )
  end

  def self.from_fragment(fragment, ref:, level:, start:, stop:, group_by:)
    level ||= fragment.level + 1

    new(
      id: fragment.document.urn,
      cite_depth: fragment.document.cite_depth,
      ref: ref,
      level: level,
      start: start,
      stop: stop,
      group_by: group_by,
      member_proc: fragment_member_proc(fragment, level),
    )
  end

  def self.document_member_proc(document, level)
    -> { document.fragments.where(level: level).order(:rank) }
  end

  def self.document_member_start_end_proc(level, start_fragment, stop_fragment)
    lambda do
      start_rank = start_fragment.rank
      stop_rank = stop_fragment.descendent_rank

      start_fragment.document.fragments.where(rank: (start_rank..stop_rank), level: level).order(:rank)
    end
  end

  def self.fragment_member_proc(fragment, level)
    -> { fragment.document.fragments.where(rank: (fragment.rank..fragment.descendent_rank), level: level).order(:rank) }
  end

  private_class_method :document_member_proc, :document_member_start_end_proc, :fragment_member_proc

  def valid?
    return false if ref && start
    return false unless start_and_stop_valid?

    true
  end

  def json
    {
      '@context': {
        '@vocab': 'https://www.w3.org/ns/hydra/core#',
        dc: 'http://purl.org/dc/terms/',
        dts: 'https://w3id.org/dts/api#',
      },
      '@id': navigation_id,
      'dts:citeDepth': cite_depth_number,
      'dts:level': level,
      'dts:passage': passage_path,
    }.merge(member_json)
  end

  private

  def start_and_stop_valid?
    (start && stop) || (!start && !stop)
  end

  def navigation_id
    args = {
      id: id,
      level: level,
      start: start,
      end: stop,
      ref: ref,
      groupBy: group_by,
    }.compact

    navigation_path(args)
  end

  def member_json
    references = member_proc.call

    return {} if references.empty?

    { member: ReferencesPresenter.from_fragments(references, group_by: group_by) }
  end

  def cite_depth_number
    cite_depth.to_i
  end

  def passage_path
    "#{documents_path(id: id)}{&ref}{&start}{&end}"
  end
end
