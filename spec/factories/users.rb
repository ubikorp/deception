Factory.define :user do |f|
  f.sequence(:login) { |n| "user#{n}" }
  f.sequence(:twitter_id) { |n| "100000#{n}" }
end

Factory.define :nick, :parent => :user do |f|
  f.login      'zapnap'
  f.twitter_id '1566201'
end

Factory.define :jeff, :parent => :user do |f|
  f.login      'jeffrafter'
  f.twitter_id '4176991'
end

Factory.define :darcy, :parent => :user do |f|
  f.login      'sutto'
  f.twitter_id '5099921'
end

Factory.define :aaron, :parent => :user do |f|
  f.login      'aaronstack'
  f.twitter_id '49659252'
end

Factory.define :elsa, :parent => :user do |f|
  f.login      'ebloodstone'
  f.twitter_id '49659649'
end
