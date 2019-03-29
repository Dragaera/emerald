module Emerald
  module Config
    def self.to_bool(v)
      ['y', '1', 'true'].include? v.to_s.downcase
    end

    module Sentry
      DSN = ENV['SENTRY_DSN']

      def self.enabled?
        DSN && !DSN.empty?
      end
    end
  end
end
