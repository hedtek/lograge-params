require 'useragent'

# Just use lograge unless disabled
ENV['USE_LOGRAGE'] ||= 'true'

module LogrageParams
  class Engine < ::Rails::Engine
    config.lograge.custom_options = lambda do |event|
      begin
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

        if event.payload[:browser]
          user_agent = UserAgent.parse(event.payload[:browser])
          browser_log = {
            user_agent: event.payload[:browser],
            browser: user_agent.browser,
            platform: user_agent.platform,
            browser_version: user_agent.version,
            browser_combined: "#{user_agent.browser}-#{user_agent.version}",
            platform_combined: "#{user_agent.platform}-#{user_agent.browser}-#{user_agent.version}"
          }

        else
          browser_log = {
            browser: "Unknown"
          }
        end

        params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }.each_with_object({}, &flattener)

        params.values.each{|v| v.gsub!(" ", "_")}
        browser_log.values.each{|v| v.gsub!(" ", "_")}
        config.lograge.static_data.merge(browser_log).merge(params).merge(event.payload[:users])
      rescue
        {}
      end
    end

    if ENV['USE_LOGRAGE'] == 'true'
      config.lograge.enabled = true
    else
      config.lograge.enabled = false
    end

    config.lograge.static_data ||= {}

    initializer 'lograge-params.add_controller_hook' do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, LogrageParams::Controller)
      end
    end
  end
end
