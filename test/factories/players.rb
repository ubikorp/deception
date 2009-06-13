Factory.define :player do |f|
  # ...
end

Factory.define :werewolf, :parent => :player do |f|
  f.association :game
  f.association :user, :factory => :nick
end

Factory.define :villager, :parent => :player do |f|
  f.association :game
  f.association :user, :factory => :jeff
end
