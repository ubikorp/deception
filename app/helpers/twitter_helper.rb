module TwitterHelper
  def twitter_profile_url(user)
    "http://twitter.com/#{user.login}"
  end

  def twitter_name(user)
    "@#{user.login}"
  end

  def profile_image(user, options = {})
    alt = "#{user.name} (@#{user.login})"
    options[:alt] ||= alt
    options[:title] ||= alt
    image_url = user.profile_image_url || 'http://static.twitter.com/images/default_profile_normal.png'
    image_tag(image_url, options)
  end
end
