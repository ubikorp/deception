Then /^I should be following the gamebot user on Twitter$/ do
  User.find_by_login('zapnap').should be_following
end
