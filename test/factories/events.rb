Factory.define :event do |f|
  # ...
end

Factory.define :vote_event, :parent => :event do |f|
  f.association :game
  f.association :source_player, :factory => :villager
  f.association :target_player, :factory => :werewolf
end
