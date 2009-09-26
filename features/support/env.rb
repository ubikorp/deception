# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'spec/stubs/cucumber'
require "spec/mocks"

# Whether or not to run each scenario within a database transaction.
#
# If you leave this to true, you can turn off traqnsactions on a
# per-scenario basis, simply tagging it with @no-txn
Cucumber::Rails::World.use_transactional_fixtures = true

# Whether or not to allow Rails to rescue errors and render them on
# an error page. Default is false, which will cause an error to be
# raised.
#
# If you leave this to false, you can turn on Rails rescuing on a
# per-scenario basis, simply tagging it with @allow-rescue
ActionController::Base.allow_rescue = false

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

require 'ruby-debug'
require 'webrat'
require 'cucumber/webrat/element_locator' # Lets you do table.diff!(element_at('#my_table_or_dl_or_ul_or_ol').to_table)

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false # Set to true if you want error pages to pop up in the browser
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:post, 'http://twitter.com/oauth/request_token', :body => 'oauth_token=fake&oauth_token_secret=fake')
FakeWeb.register_uri(:post, 'http://twitter.com/oauth/access_token', :body => 'oauth_token=fake&oauth_token_secret=fake')
FakeWeb.register_uri(:get, 'http://twitter.com/account/verify_credentials.json', :response => File.join(RAILS_ROOT, 'features', 'fixtures', 'verify_credentials.json'))
FakeWeb.register_uri(:get, 'http://twitter.com/statuses/followers.json', :response => File.join(RAILS_ROOT, 'features', 'fixtures', 'followers.json'))
FakeWeb.register_uri(:get, 'http://twitter.com/statuses/followers.json?page=1', :response => File.join(RAILS_ROOT, 'features', 'fixtures', 'followers.json'))
# FakeWeb.register_uri(:get, 'http://twitter.com/friendships/show.json', :response => File.join(RAILS_ROOT, 'features', 'fixtures', 'friendship.json'))
FakeWeb.register_uri(:post, 'http://twitter.com/friendships/create/t3stx.json?follow=true', :body => '', :response => File.join(RAILS_ROOT, 'features', 'fixtures', 'create_friendship.json'))
FakeWeb.register_uri(:post, %r|http://(\w+:\w+@)?twitter.com/friendships/create/\w+.json|, :body => '')
FakeWeb.register_uri(:post, 'http://twitter.com/direct_messages/new.json', :body => '')

module Webrat
  module Locators  
    class Locator # :nodoc:
      def locate!
        locate || raise(NotFoundError.new(error_message))        
      rescue Webrat::NotFoundError => e
        raise "#{e.message}\n#{@session.send(:response_body).gsub(/\n/, "\n  ")}"  
      end
    end
  end
end

Before do
  $rspec_mocks ||= Spec::Mocks::Space.new
  GameBot.stub!(:messages).and_return(mock('BirdGrinderClient', :null_object => true))
  GameBot.stub!(:twitter).and_return(mock('Twitter', :null_object => true))
end

After do
  begin
    $rspec_mocks.verify_all
  ensure
    $rspec_mocks.reset_all
  end
end
