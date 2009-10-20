module Rails
  # Stupid annoying bug.
  unless defined?(Rails::VERSION)
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 3
      TINY  = 4

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
