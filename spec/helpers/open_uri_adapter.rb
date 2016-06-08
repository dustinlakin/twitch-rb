require 'open-uri'

module Twitch
  module Adapters
    class OpenURIAdapter < BaseAdapter
      def self.request(method, url, options={})
        if (method == :get)
          ret = {}

          open(url) do |io|
            ret[:body] = JSON.parse(io.read)
            ret[:response] = io.status.first.to_i
          end

          ret
        end
      end
    end # class OpenURIAdapter
  end # module Adapters
end # module Twitch