module LogrageParams
  module UserLogger
    def self.to_hash(event)
      event.payload[:users] || {}
    rescue
      {:user_logger => "User-Error-logging-users"}
    end
  end
end
