# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

# Comment out the next line if you don't want transactions to
# open/roll back around each scenario
Cucumber::Rails.use_transactional_fixtures

# Comment out the next line if you want Rails' own error handling
# (e.g. rescue_action_in_public / rescue_responses / rescue_from)
Cucumber::Rails.bypass_rescue

require 'ruby-debug'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
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
