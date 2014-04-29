module LogrageParams
  module Controller
    def append_info_to_payload(payload)
      super

      payload[:params] = request.params
      devise_users = methods.grep(/^current_/).each_with_object({}) do |m, hsh|
        user_type = m.to_s.gsub(/^current_/, '')
        u = send(m)
        hsh[user_type] = u if u
      end

      if devise_users.empty?
        payload[:user] = "None"
      else
        devise_users.each do |type, user|
          payload[type] = current_user.id
        end
      end
    end
  end
end
