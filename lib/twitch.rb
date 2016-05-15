require 'twitch/adapters'
require 'twitch/request'
require 'twitch/version'
require 'twitch/user'
require 'twitch/client'

module Twitch
  def self.new(options={})
    Twitch::Client.new(options)
  end
end
