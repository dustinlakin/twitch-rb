# frozen_string_literal: true

module Twitch
  class ServerError < StandardError
    def initialize(status)
      super "Server Error #{status}"
    end
  end
end
