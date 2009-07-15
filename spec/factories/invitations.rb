Factory.define :invitation do |f|
  f.association   :game
  f.twitter_login 'pat'
  f.association   :invited_by, :factory => :user
end
