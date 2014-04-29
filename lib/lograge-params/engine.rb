ENV['USE_LOGRAGE'] ||= 'true' if Rails.env.production?

module LogrageParams
  class Engine < ::Rails::Engine
    if ENV['USE_LOGRAGE'] == 'true'
      config.lograge.enabled = true

      config.lograge.custom_options = lambda do |event|
        unwanted_keys = %w[format action controller
                           utf8 authenticity_token commit]
        flattener = proc do |(k, v), h, prefix='params'|
          key = [prefix, k].compact.join("/")
          if %w(password password_confirmation).include? k
            h[key] = "[FILTERED]"
          elsif v.is_a?(Hash)
            v.each {|p| flattener.call(p, h, key)}
          else
            h[key] = "'#{v}'"
          end
        end

        params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }.each_with_object({}, &flattener)
        {:user => event.payload[:user], :browser => event.payload[:browser] }.merge(params)
      end

      initializer 'lograge-params.add_controller_hook' do
        ActiveSupport.on_load :action_controller do
          ActionController::Base.send(:include, LogrageParams::Controller)
        end
      end
    else
      config.lograge.enabled = false
    end
  end
end
