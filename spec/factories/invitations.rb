Factory.define :invitation do |f|
  f.association   :game
  f.twitter_login 'nickplante'
  f.association   :invited_by, :factory => :user
end
