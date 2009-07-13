Factory.define :event do |f|
  f.association :period, :factory => :first_period
  f.association :source_player, :factory => :werewolf
  # ...
end

Factory.define :vote_event, :class => VoteEvent do |f|
  f.association :source_player, :factory => :werewolf
  f.association :target_player, :factory => :villager
end

Factory.define :kill_event, :class => KillEvent do |f|
  f.association :target_player, :factory => :werewolf
end

Factory.define :quit_event, :class => QuitEvent do |f|
  f.association :source_player, :factory => :werewolf
end
