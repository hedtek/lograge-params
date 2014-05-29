require 'useragent'

module LogrageParams
  class Engine < ::Rails::Engine
    config.lograge.custom_options = lambda do |event|
      begin
        flattener = proc do |(k, v), h, prefix='params'|
          key = [prefix, k].compact.join("/")
          if config.lograge.filter_keys.include? k
            h[key] = "[FILTERED]"
          elsif v.is_a?(Hash)
            v.each {|p| flattener.call(p, h, key)}
          else
            h[key] = "'#{v}'".gsub(" ", "_")
          end
        end

        if config.lograge.log_browser
          if event.payload[:browser]
            user_agent = UserAgent.parse(event.payload[:browser])
            browser_log = {
              user_agent: event.payload[:browser].gsub(" ", "_"),
              browser: user_agent.browser.gsub(" ", "_"),
              platform: user_agent.platform.gsub(" ", "_"),
              browser_version: user_agent.version.gsub(" ", "_"),
              browser_combined: "#{user_agent.browser}-#{user_agent.version}".gsub(" ", "_"),
              platform_combined: "#{user_agent.platform}-#{user_agent.browser}-#{user_agent.version}".gsub(" ", "_")
            }
          else
            browser_log = {
              browser: "Unknown"
            }
          end
        else
          browser_log = {}
        end

        if config.lograge.log_params
          params = event.payload[:params].reject { |key,_| config.lograge.ignore_keys.include? key }.each_with_object({}, &flattener)
        else
          params = {}
        end

        if config.lograge.log_users
          users = event.payload[:users]
        else
          users = {}
        end

        config.lograge.static_data.merge(browser_log).merge(params).merge(users)
      rescue
        {}
      end
    end

    config.lograge.enabled = true
    config.lograge.static_data ||= {}
    config.lograge.ignore_keys = %w[format action controller utf8 authenticity_token commit]
    config.lograge.filter_keys = %w(password password_confirmation)
    config.lograge.log_users = true
    config.lograge.log_params = true
    config.lograge.log_browser = true

    initializer 'lograge-params.add_controller_hook' do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, LogrageParams::Controller)
      end
    end
  end
end
