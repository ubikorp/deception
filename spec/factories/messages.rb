Factory.define :outgoing_message do |f|
  f.association :game
  f.association :to_user, :factory => :nick
  f.text        "You've been killed, dude."
end

Factory.define :incoming_message do |f|
  f.association :game
  f.association :from_user, :factory => :jeff
  f.text        "@gamebot I vote to kill @zapnap"
end
