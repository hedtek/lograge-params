module LogrageParams
  module Controller
    def append_info_to_payload(payload)
      super
      if Rails.application.config.lograge.enabled
        capture_users(payload) if Rails.application.config.lograge.log_users
        capture_params(payload) if Rails.application.config.lograge.log_params
        capture_browser(payload) if Rails.application.config.lograge.log_browser
        capture_referer(payload) if Rails.application.config.lograge.log_referer
        capture_ip(payload) if Rails.application.config.lograge.log_ips
      end
    end

    def capture_users(payload)
      payload[:users] = {}
      methods.grep(/^current_.*[^=]$/).each_with_object(payload[:users]) do |m, hsh|
        next if m == :current_inviter # This is badly implemented in devise_invitable. Skip it
        next if m == :current_ability # This isn't anything we care about logging. It's from cancan
        begin
          user_type = m.to_s.gsub(/^current_/, '')
          u = send(m)
          hsh[user_type] = u.id if u && u.respond_to?(:id)
        rescue
        end
      end
      if payload[:users].empty?
        payload[:users][:user] = "None"
      end
    end

    def capture_params(payload)
      payload[:params] = request.params
    end

    def capture_browser(payload)
      payload[:browser] = request.user_agent
    end

    def capture_referer(payload)
      payload[:referer] = request.referer
    end

    def capture_ip(payload)
      payload[:ip] = request.remote_ip
    end
  end
end
