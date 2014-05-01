module LogrageParams
  module Controller
    def append_info_to_payload(payload)
      super

      payload[:params] = request.params

      payload[:users] = {}
      methods.grep(/^current_/).each_with_object(payload[:users]) do |m, hsh|
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
