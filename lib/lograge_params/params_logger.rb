module LogrageParams
  module ParamsLogger
    def self.to_hash(event)
      filtered_params = Rails.application.config.lograge.filter_keys
      ignored_keys = Rails.application.config.lograge.ignore_keys

      flattener = proc do |(k, v), h, prefix='params'|
        key = [prefix, k].compact.join("/")
        if filtered_params.include? k
          h[key] = "[FILTERED]"
        elsif v.is_a?(Hash)
          v.each {|p| flattener.call(p, h, key)}
        else
          h[key] = "'#{v}'".gsub(" ", "_")
        end
      end

      event.payload[:params].reject{|key,_| ignored_keys.include? key }.each_with_object({}, &flattener)
    end
  end
end
