Factory.define :event do |f|
  # ...
end

Factory.define :vote_event, :class => VoteEvent do |f|
  f.association :game
  f.association :source_player, :factory => :villager
  f.association :target_player, :factory => :werewolf
end

Factory.define :kill_event, :class => KillEvent do |f|
  f.association :game
  f.association :target_player, :factory => :werewolf
end

Factory.define :quit_event, :class => QuitEvent do |f|
  f.association :game
  f.association :source_player, :factory => :werewolf
end
