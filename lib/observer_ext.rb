module ActiveRecord
  class Observer
    def logger
      RAILS_DEFAULT_LOGGER
    end
  end
end
