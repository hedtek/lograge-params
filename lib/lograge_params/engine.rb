module LogrageParams
  class Engine < ::Rails::Engine
    config.lograge.custom_options = lambda do |event|
      begin
        data = config.lograge.static_data
        config.lograge.configured_loggers.inject(data) do |d, logger|
          begin
            d.merge(logger.to_hash(event))
          rescue
            d.merge("#{logger.name}-error" => "Error-processing")
          end
        end
      rescue => e
        Rails.logger.warn("Error logging request: #{e.message}\n#{e.backtrace.join("\n\t")}")
        config.lograge.static_data.merge(:error => "Error-logging")
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
    config.lograge.log_ip = true
    config.lograge.configured_loggers ||= []

    initializer 'lograge_params.add_controller_hook' do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, LogrageParams::Controller)
      end
    end

    initializer 'lograge_params.setup_loggers' do
      loggers = config.lograge.configured_loggers

      if config.lograge.log_users
        require 'lograge_params/user_logger'
        loggers << LogrageParams::UserLogger
      end

      if config.lograge.log_params
        require 'lograge_params/params_logger'
        loggers << LogrageParams::ParamsLogger
      end

      if config.lograge.log_browser
        require 'lograge_params/browser_logger'
        loggers << LogrageParams::BrowserLogger
      end

      if config.lograge.log_ip
        require 'lograge_params/ip_logger'
        loggers << LogrageParams::IPLogger
      end

      if config.lograge.log_referer
        require 'lograge_params/referer_logger'
        loggers << LogrageParams::RefererLogger
      end

      loggers.uniq!
    end
  end
end
