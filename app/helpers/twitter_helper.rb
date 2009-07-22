module TwitterHelper
  def twitter_profile_url(user)
    "http://twitter.com/#{user.login}"
  end

  def twitter_name(user)
    "@#{user.login}"
  end

  def profile_image(user, options = {})
    alt = "#{user.name} (@#{user.login})"
    image_tag(user.profile_image_url || 'http://static.twitter.com/images/default_profile_normal.png', :alt => alt, :title => alt)
  end
end
