require 'httparty'

module Twitch
  module Adapters
    class DebugHTTPartyAdapter < BaseAdapter
      def self.request(method, url, options={})
        res = HTTParty.send(method, url, options.merge(:debug_output => $debug_output))
        {:body => res, :response => res.code}
      end
    end
  end
end
