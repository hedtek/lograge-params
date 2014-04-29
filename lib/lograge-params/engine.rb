require 'useragent'

# Just use lograge unless disabled
ENV['USE_LOGRAGE'] ||= 'true'

module LogrageParams
  class Engine < ::Rails::Engine
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

      user_agent = UserAgent.parse(event.payload[:browser])
      browser_log = {
        browser: user_agent.browser,
        platform: user_agent.platform,
        browser_version: user_agent.version
      }

      params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }.each_with_object({}, &flattener)
      browser_log.merge(params).merge(event.payload[:users])
    end

    if ENV['USE_LOGRAGE'] == 'true'
      config.lograge.enabled = true
    else
      config.lograge.enabled = false
    end

    initializer 'lograge-params.add_controller_hook' do

      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, LogrageParams::Controller)
      end
    end
  end
end
