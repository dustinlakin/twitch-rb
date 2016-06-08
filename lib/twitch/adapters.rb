require 'twitch/adapters/base_adapter'
require 'twitch/adapters/httparty_adapter'

module Twitch
  module Adapters
    DEFAULT_ADAPTER = Twitch::Adapters::HTTPartyAdapter

    def get_adapter(adapter, default_adapter = DEFAULT_ADAPTER)
      begin
        Twitch::Adapters.const_defined?(adapter.to_s)
      rescue
        default_adapter
      else
        adapter
      end
    end
  end
end
