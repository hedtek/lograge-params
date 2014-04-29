module LogrageParams
  module Controller
    def append_info_to_payload(payload)
      super
      payload[:params] = request.params
      if defined?(current_user) && current_user
        payload[:user] = current_user.id
      else
        payload[:user] = "None"
      end
    end
  end
end
