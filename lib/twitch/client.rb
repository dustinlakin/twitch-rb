# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'twitch_oauth2'

require_relative 'server_error'

require 'retriable'
Retriable.configure do |config|
  config.contexts[:twitch] = {
    on: [
      Errno::ETIMEDOUT,
      SocketError,
      Faraday::ConnectionFailed,
      Faraday::TimeoutError,
      Twitch::ServerError
    ],
    ## It will last for 42 minutes max (remember about `rand_factor`, default is `0.5`),
    ## the last interval is 21 minutes max
    tries: 10,
    base_interval: 5,
    multiplier: 2,
    max_interval: 30 * 60, ## 30 minutes
    max_elapsed_time: 60 * 60 ## 1 hour
  }
end

module Twitch
  class Client
    DEFAULT_CONNECTION = Faraday.new(
      url: 'https://api.twitch.tv/kraken',
      headers: {
        'Accept' => 'application/vnd.twitchtv.v5+json'
      }
    ) do |connection|
      connection.request :json

      connection.response :dates
      connection.response :json, content_type: /\bjson$/, parser_options: { symbolize_names: true }
    end.freeze

    private_constant :DEFAULT_CONNECTION

    attr_reader :connection, :tokens

    def initialize(options = {})
      @client_id = options[:client_id]

      @oauth2_client = TwitchOAuth2::Client.new(
        client_id: @client_id,
        **options.slice(:client_secret, :redirect_uri, :scopes)
      )

      @tokens = options.slice(:access_token, :refresh_token)

      @connection = options.fetch(:connection, DEFAULT_CONNECTION.dup)
      connection.headers['Client-ID'] = @client_id

      renew_authorization_header if access_token
    end

    %i[access_token refresh_token].each do |key|
      define_method key do
        tokens[key]
      end
    end

    def check_tokens!
      @tokens = @oauth2_client.check_tokens(**tokens)
    end

    # User

    def user(user_id = nil)
      return your_user unless user_id

      request :get, "users/#{user_id}"
    end

    def your_user
      require_access_token do
        request :get, 'user'
      end
    end

    def users(*logins)
      request :get, 'users', login: logins.join(',')
    end

    # Teams

    def teams
      request :get, 'teams'
    end

    def team(team_id)
      request :get, "teams/#{team_id}"
    end

    # Channel

    def channel(channel_id = nil)
      return your_channel unless channel_id

      request :get, "channels/#{channel_id}"
    end

    def your_channel
      require_access_token do
        request :get, 'channel'
      end
    end

    def editors(channel)
      require_access_token do
        request :get, "channels/#{channel}/editors"
      end
    end

    def update_channel(channel_id, options)
      require_access_token do
        request :put, "channels/#{channel_id}", channel: options
      end
    end

    def reset_key(channel)
      require_access_token do
        request :delete, "channels/#{channel}/stream_key"
      end
    end

    def follow_channel(username, channel)
      require_access_token do
        request :put, "users/#{username}/follows/channels/#{channel}"
      end
    end

    def unfollow_channel(username, channel)
      require_access_token do
        request :delete, "users/#{username}/follows/channels/#{channel}"
      end
    end

    def run_commercial(channel, length = 30)
      require_access_token do
        request :post, "channels/#{channel}/commercial", length: length
      end
    end

    def channel_teams(channel)
      require_access_token do
        request :get, "channels/#{channel}/teams"
      end
    end

    # Streams

    def stream(channel_id, options = {})
      request :get, "streams/#{channel_id}", options
    end

    def streams(options = {})
      request :get, 'streams', options
    end

    def featured_streams(options = {})
      request :get, 'streams/featured', options
    end

    def summarized_streams(options = {})
      request :get, 'streams/summary', options
    end

    def followed_streams(options = {})
      require_access_token do
        request :get, 'streams/followed', options
      end
    end
    alias your_followed_streams followed_streams

    # Games

    def top_games(options = {})
      request :get, 'games/top', options
    end

    # Search

    def search_channels(options = {})
      request :get, 'search/channels', options
    end

    def search_streams(options = {})
      request :get, 'search/streams', options
    end

    def search_games(options = {})
      request :get, 'search/games', options
    end

    # Videos

    def channel_videos(channel, options = {})
      request :get, "channels/#{channel}/videos", options
    end

    def video(video_id)
      request :get, "videos/#{video_id}"
    end

    def subscribed?(username, channel, options = {})
      request :get, "users/#{username}/subscriptions/#{channel}", options
    end

    def followed_videos(options = {})
      require_access_token do
        request :get, 'videos/followed', options
      end
    end
    alias your_followed_videos followed_videos

    def top_videos(options = {})
      request :get, 'videos/top', options
    end

    # Blocks

    def blocks(username, options = {})
      request :get, "users/#{username}/blocks", options
    end

    def block_user(username, target)
      require_access_token do
        request :put, "users/#{username}/blocks/#{target}"
      end
    end

    def unblock_user(username, target)
      require_access_token do
        request :delete, "users/#{username}/blocks/#{target}"
      end
    end

    # Chat

    def badges(channel_id)
      request :get, "chat/#{channel_id}/badges"
    end

    def emoticons
      request :get, 'chat/emoticons' do |request|
        request.headers.delete 'Authorization'
      end
    end

    # Follows

    def following(channel_id, options = {})
      request :get, "channels/#{channel_id}/follows", options
    end

    def followed(user_id, options = {})
      request :get, "users/#{user_id}/follows/channels", options
    end

    def follow_status(user_id, channel_id)
      request :get, "users/#{user_id}/follows/channels/#{channel_id}"
    end

    # Ingests

    def ingests
      request :get, 'ingests'
    end

    # Root

    def root
      request :get, ''
    end

    # Subscriptions

    def subscribed(channel, options = {})
      require_access_token do
        request :get, "channels/#{channel}/subscriptions", options
      end
    end

    def subscribed_to_channel(username, channel)
      require_access_token do
        request :get, "channels/#{channel}/subscriptions/#{username}"
      end
    end

    private

    def renew_authorization_header
      connection.headers['Authorization'] = "OAuth #{access_token}"
    end

    def request(http_method, *args)
      Retriable.with_context(:twitch) do
        response = connection.public_send http_method, *args

        raise ServerError.new(response.status) if response.status.between?(500, 599)

        response
      end
    end

    def require_access_token
      response = yield
      if response.success? ||
          response.status != 401 ||
          ## Here can be another error, like "missing required oauth scope"
          response.body[:message] != 'invalid oauth token'
        return response
      end

      @tokens = @oauth2_client.refreshed_tokens(refresh_token: refresh_token)
      renew_authorization_header
      yield
    end
  end
end
