Factory.define :player do |f|
  # ...
end

Factory.define :werewolf, :class => Werewolf do |f|
  f.association :game
  f.association :user, :factory => :nick
  f.dead        false
end

Factory.define :villager, :class => Villager do |f|
  f.association :game
  f.association :user, :factory => :jeff
  f.dead        false
end
