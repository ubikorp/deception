# oauth gem 0.3.5 send oob as the oauth_callback parameter which forces twitter into desktop mode
# this patches oauth gem to send a blank value instead
module OAuth
  if defined?(OUT_OF_BAND)
    self.send('remove_const','OUT_OF_BAND')
    OUT_OF_BAND = ""
  end
end
