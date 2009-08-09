class UserObserver < ActiveRecord::Observer
  # auto-follow the new user
  def after_create(user)
    Message.twitter.friendship_create(user.login)
  end
end
