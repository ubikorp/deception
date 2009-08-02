Factory.define :outgoing_message do |f|
  f.association :game
  f.association :to_user, :factory => :nick
  f.text        "You've been killed, dude."
end

Factory.define :incoming_message do |f|
  f.association :game
  f.association :from_user, :factory => :jeff
  f.text        "I vote to kill @zapnap"
  f.sequence(:status_id) { |n| "100000#{n}" }
end
