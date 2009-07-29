module UsersHelper
  def newest_users
    User.find(:all, :limit => 10, :order => "created_at DESC")
  end
end
