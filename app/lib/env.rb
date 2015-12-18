module App
  # Load ENV_ prefixed properties from Info.plist
  module Env
    class << self
      def [](key)
        vars["ENV_#{key}"]
      end

      def vars
        @vars ||= info_dictionary.select { |key, _| key.start_with? "ENV_" }
      end

      def info_dictionary
        NSBundle.mainBundle.infoDictionary
      end
    end
  end
end
