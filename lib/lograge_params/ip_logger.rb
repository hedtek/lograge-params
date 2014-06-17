module LogrageParams
  module IPLogger
    def self.to_hash(event)
      event.payload[:ip] || {}
    end
  end
end

