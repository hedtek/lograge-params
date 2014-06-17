module LogrageParams
  module IPLogger
    def self.to_hash(event)
      {
        remote_ip: event.payload[:ip]
      }
    end
  end
end

