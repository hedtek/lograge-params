module LogrageParams
  module UserLogger
    def self.to_hash(event)
      event.payload[:users] || {}
    end
  end
end
