class StartStopNavigationPresenter < ApplicationPresenter
  attr_accessor :document, :start, :stop, :level

  def initialize(document, start, stop, level:)
    @document = document
    @start = start
    @stop = stop
    @level = level || start.level
  end

  def members
    start_rank = start.rank
    stop_rank = stop.descendent_rank

    document.fragments.where(rank: (start_rank..stop_rank), level: level).order(:rank)
  end
end
