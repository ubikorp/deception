class EventObserver < ActiveRecord::Observer
  # short-circuit period ending if all votes are in
  def after_create(event)
    if [VoteEvent, QuitEvent].include? event.class
      event.game.continue if event.period.finished?
    end
  end
end
