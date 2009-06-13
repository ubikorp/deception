Factory.define :user do |f|
  # ...
end

Factory.define :nick, :parent => :user do |f|
  f.login      'zapnap'
  f.twitter_id 'zapnap'
end

Factory.define :jeff, :parent => :user do |f|
  f.login      'njero'
  f.twitter_id 'jeffrafter'
end

Factory.define :darcy, :parent => :user do |f|
  f.login      'sutto'
  f.twitter_id 'sutto'
end
