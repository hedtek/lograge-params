module LogrageParams
  module Controller
    def append_info_to_payload(payload)
      super

      if ENV["USE_LOGRAGE"]
        payload[:params] = request.params

        payload[:users] = {}
        methods.grep(/^current_/).each_with_object(payload[:users]) do |m, hsh|
          next if m == :current_inviter # This is badly implemented in devise_invitable. Skip it
          next if m == :current_ability # This isn't anything we care about logging. It's from cancan
          user_type = m.to_s.gsub(/^current_/, '')
          u = send(m)
          hsh[user_type] = u.id if u && u.respond_to?(:id)
        end
        if payload[:users].empty?
          payload[:users][:user] = "None"
        end

        payload[:browser] = request.user_agent
      end
    end
  end
end
