Factory.define :period do
  # ...
end

Factory.define :first_period, :parent => :period do |f|
  f.association :game
end
