require 'useragent'

module LogrageParams
  module BrowserLogger
    def self.to_hash(event)
      if event.payload[:browser]
        user_agent = UserAgent.parse(event.payload[:browser])

        {
          user_agent: event.payload[:browser].gsub(" ", "_"),
          browser: user_agent.browser.to_s.gsub(" ", "_"),
          platform: user_agent.platform.to_s.gsub(" ", "_"),
          browser_version: user_agent.version,
          browser_combined: "#{user_agent.browser}-#{user_agent.version}".gsub(" ", "_"),
          platform_combined: "#{user_agent.platform}-#{user_agent.browser}-#{user_agent.version}".gsub(" ", "_")
        }
      else
        {browser: "Unknown"}
      end
    end
  end
end
