Factory.define :user do |f|
  f.sequence(:login) { |n| "user#{n}" }
  f.sequence(:twitter_id) { |n| "100000#{n}" }
end

Factory.define :zapnap, :parent => :user do |f|
  f.login      'zapnap'
  f.twitter_id '1566201'
end

Factory.define :jeffrafter, :parent => :user do |f|
  f.login      'jeffrafter'
  f.twitter_id '4176991'
end

Factory.define :sutto, :parent => :user do |f|
  f.login      'sutto'
  f.twitter_id '5099921'
end

Factory.define :aaronstack, :parent => :user do |f|
  f.login      'aaronstack'
  f.twitter_id '49659252'
end

Factory.define :ebloodstone, :parent => :user do |f|
  f.login      'ebloodstone'
  f.twitter_id '49659649'
end
