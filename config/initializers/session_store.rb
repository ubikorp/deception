# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_deception_session',
  :secret      => 'c1c724a6ad264dae6581bed6b589b2d908a1ee5c6f6f3df9c9bcfd32e8b2c18979c5de3f3e5f5b8040d52f6a27d83be4f20d5d3d23f8daef4690b33a6fd9fc19'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
