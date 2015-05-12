module Twitch
  module Adapters
    class BaseAdapter
      def self.get(url)
        request(:get, url)
      end

      def self.post(url, options)
        request(:post, url, options)
      end

      def self.put(url, options)
        request(:put, url, options)
      end

      def self.delete(url)
        request(:delete, url)
      end

      def self.request(method, url, options)
      end
    end
  end
end