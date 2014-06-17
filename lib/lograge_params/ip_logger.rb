module LogrageParams
  module UserLogger
    def self.to_hash(event)
      event.payload[:ip] || {}
    end
  end
end

