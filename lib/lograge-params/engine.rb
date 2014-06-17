module LogrageParams
  class Engine < ::Rails::Engine
    config.lograge.custom_options = lambda do |event|
      begin
        data = config.lograge.static_data
        config.lograge.configured_loggers.inject(data) {|d, logger| d.merge(logger.to_hash(event))}
      rescue => e
        Rails.logger.warn("Error logging request: #{e.message}\n#{e.backtrace.join("\n\t")}")
        config.lograge.static_data.merge(:error => "Error logging")
      end
    end

    config.lograge.enabled = true
    config.lograge.static_data ||= {}
    config.lograge.ignore_keys = %w[format action controller utf8 authenticity_token commit]
    config.lograge.filter_keys = %w(password password_confirmation)
    config.lograge.log_users = true
    config.lograge.log_params = true
    config.lograge.log_browser = true
    config.lograge.log_referer = true

    initializer 'lograge-params.add_controller_hook' do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, LogrageParams::Controller)
      end
    end

    initializer 'lograge-params.setup_loggers' do
      loggers = []
      config.lograge.configured_loggers = loggers

      if config.lograge.log_users
        require 'lograge-params/user_logger'
        loggers << LogrageParams::UserLogger
      end

      if config.lograge.log_params
        require 'lograge-params/params_logger'
        loggers << LogrageParams::ParamsLogger
      end

      if config.lograge.log_browser
        require 'lograge-params/browser_logger'
        loggers << LogrageParams::BrowserLogger
      end

      if config.lograge.log_referer
        require 'lograge-params/referer_logger'
        loggers << LogrageParams::RefererLogger
      end
    end
  end
end
