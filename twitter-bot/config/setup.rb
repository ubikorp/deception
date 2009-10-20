# Setup the env / start doing things.
BirdGrinder::Loader.before_run do
  DeceptionHandler.register!
end

BirdGrinder::Loader.once_running do
  # BirdGrinder::Client.current references the current client  
end
