Factory.define :message do |f|
  f.association :game
  f.target      "zapnap"
  f.text        "You've been killed, dude."
end
