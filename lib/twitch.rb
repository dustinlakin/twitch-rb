require 'twitch/adapters'
require 'twitch/client'
require 'twitch/request'
require 'twitch/version'

module Twitch
  def self.new(options={})
    Twitch::Client.new(options)
  end
end
