require 'uri'

module LogrageParams
  module RefererLogger
    def self.to_hash(event)
      if event.payload[:referer].blank?
        {referer: "None"}
      else
        begin
          url = URI(event.payload[:referer])
          {
            referer: url.host,
            referer_path: url.path,
            referer_query: url.query,
            referer_scheme: url.scheme,
            referer_url: event.payload[:referer]
          }
        rescue
          {
            referer: event.payload[:referer]
          }
        end
      end
    end
  end
end
