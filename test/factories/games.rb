Factory.define :game do |f|
  f.sequence(:name) { |n| "The Incident at Mariahville #{n}"}
  f.association :owner, :factory => :user
end
