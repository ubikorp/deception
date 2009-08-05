# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def distance_of_time_from_now(seconds)
    distance = seconds.to_i
    distance_in_hours   = (distance / 60 / 60).round
    distance_in_minutes = ((distance - distance_in_hours * 60) / 60).round
    distance_in_seconds = distance - distance_in_hours * 60 * 60 - distance_in_minutes * 60

    values = []
    values << distance_in_hours if distance_in_hours != 0
    values << distance_in_minutes if distance_in_minutes != 0
    values << distance_in_seconds
    values.join(':')
  end 
end
