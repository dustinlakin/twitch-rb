require 'httparty'

module Twitch
  module Adapters
    class HTTPartyAdapter < BaseAdapter

      def self.request(method, url, options = {})
        res = HTTParty.send(method, url, options)
        {:body => res, :response => res.code}
      end

    end
  end
end
