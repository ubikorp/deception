class ApplicationController < ActionController::Base
  include DeceptionGame::ControllerExtensions

  layout 'master'
  helper :all
end
