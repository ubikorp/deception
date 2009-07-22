Factory.define :game do |f|
  f.sequence(:name) { |n| "The Incident at Mariahville #{n}"}
  f.association :owner, :factory => :zapnap
  f.min_players 3
  f.max_players 11
  f.period_length 600
end
