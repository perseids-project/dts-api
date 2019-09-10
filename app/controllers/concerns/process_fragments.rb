module ProcessFragments
  extend ActiveSupport::Concern

  private

  def document
    @document ||= Document.find_by(urn: id)
  end

  def fragment
    @fragment ||= ref && Fragment.find_by(document: document, ref: ref)
  end

  def start_fragment
    @start_fragment ||= start && Fragment.find_by(document: document, ref: start)
  end

  def stop_fragment
    @stop_fragment ||= stop && Fragment.find_by(document: document, ref: stop)
  end

  def fragment_not_found?
    (ref && !fragment) || (start && !start_fragment) || (stop && !stop_fragment)
  end

  def id
    params[:id].presence
  end

  def start
    params[:start].presence
  end

  def stop
    params[:end].presence
  end

  def ref
    params[:ref].presence
  end
end
