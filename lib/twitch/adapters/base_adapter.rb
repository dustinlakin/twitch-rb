module Twitch
  module Adapters
    class BaseAdapter
      def self.get(url, options = {})
        request(:get, url, options)
      end

      def self.post(url, options = {})
        request(:post, url, options)
      end

      def self.put(url, options = {})
        request(:put, url, options)
      end

      def self.delete(url, options = {})
        request(:delete, url, options)
      end

      def self.request(method, url, options = {})
      end
    end
  end
end