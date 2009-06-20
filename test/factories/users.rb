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

Factory.define :aaron, :parent => :user do |f|
  f.login      'aaronstack'
  f.twitter_id 'aaronstack'
end

Factory.define :elsa, :parent => :user do |f|
  f.login      'ebloodstone'
  f.twitter_id 'ebloodstone'
end
