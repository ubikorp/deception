class ApplicationController < ActionController::Base
  layout 'master'
  helper :all

  # before filter
  def set_default_illustration
    @illustration = Illustration.find_by_title(default_illustration_title.to_s)
  end

  # name of the default illustration for controller actions
  def default_illustration_title
    self.class.default_illustration_title
  end

  cattr_accessor :default_illustration_title

  class << self
    # Install a default illustration for controller actions
    # example:
    #
    # default_illustration :villagers
    def default_illustration(title, options = {})
      self.default_illustration_title = title
      before_filter(:set_default_illustration, options)
    end
  end
end
