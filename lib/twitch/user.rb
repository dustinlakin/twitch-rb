module Twitch
  # Features:
  #  1. Error checking
  #  2. Intuitive queries
  #
  # Issues:
  #  1. Need tests... Something is bound to be incorrect in this pile of code
  #
  # Notes:
  #  1. User and channel are used interchangeably
  #  2. I want to keep this class separate from the rest of the code so it will not break
  #     from changes in other classes/modules
  #     That is why I have chosen to include items that should normally not belong here e.g. BASE_URL
  #
  # Methods:
  #  #editors
  #  #edit_channel
  #  #reset_key
  #  #follow_channel
  #  #unfollow_channel
  #  #run_commercial
  #  #channel_teams
  #  #subscribed?
  #  #blocks
  #  #block_user
  #  #unblock_user
  #  #following
  #  #followed
  #  #follow_status
  #  #subscriptions
  #  #subscribed_to_channel
  class User
    include Twitch::Request
    include Twitch::Adapters

    BASE_URL = "https://api.twitch.tv/kraken".freeze

    def initialize(access_token)

      @adapter = get_adapter(nil)
      user_info = get_user_info(access_token)

      @access_token = access_token
      @display_name = user_info["display_name"]
      @id = user_info["_id"]
      @name = user_info["name"]
      @type = user_info["type"]
      @bio = user_info["bio"]
      @created_at = user_info["created_at"]
      @updated_at = user_info["updated_at"]
      @logo = user_info["logo"]
      @email = user_info["email"]
    end

    # Passed along in requests that require user authentication
    attr_reader :access_token

    # User friendly display name
    attr_reader :display_name

    # Unique twitch id
    attr_reader :id

    # Unique twitch name
    attr_reader :name

    # Twitch account type
    # Example: "user"
    attr_reader :type

    # Short description of channel set by user
    attr_reader :bio

    # When twitch account was created
    attr_reader :created_at

    # When twitch account was last updated/changed
    attr_reader :updated_at

    # URL to channel logo with default size of 300x300
    attr_reader :logo

    # Email associated with twitch
    attr_reader :email

    # returns a list of user objects who are editors of the channel
    def editors
      path = "/channels/#{@name}/editors?oauth_token=#{@access_token}"
      url = BASE_URL + path

      info = get(url)

      check_error(info)
    end

    # broken right now
    def edit_channel(status, game)
      path = "/channels/#{@name}/?oauth_token=#{@access_token}"
      url = BASE_URL + path
      data = {
          :channel =>{
              :game => game,
              :status => status
          }
      }

      check_error(put(url, data))
    end

    # reset your key for streaming
    # Note: You will have to update you stream key in whatever broadcasting software you are using
    def reset_key
      path = "/channels/#{@name}/stream_key?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error(delete(url))
    end

    # add a channel to your follower's list
    def follow_channel(channel)
      path = "/users/#{@name}/follows/channels/#{channel}?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error put(url)
    end

    # remove a channel from your follower's list
    def unfollow_channel(channel)
      path = "/users/#{@name}/follows/channels/#{channel}?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error delete(url)
    end

    # Run a commercial for your stream
    # Note: your channel must be a partner with twitch
    def run_commercial(length = 30)
      path = "/channels/#{@name}/commercial?oauth_token=#{@access_token}"
      url = BASE_URL + path
      info = post(url, {:length => length})

      check_error info
    end

    # Returns teams that a channel belongs to
    def channel_teams
      path = "/channels/#{@name}/teams?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error get(url)
    end

    # Check to see if user is subscribed to specified channel
    def subscribed?(channel, options = {})
      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/users/#{@name}/subscriptions/#{channel}"
      url = BASE_URL + path + query

      check_error get(url)
    end

    # A list of objects that user has blocked
    def blocks(options = {})
      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/users/#{@name}/blocks"
      url = BASE_URL + path + query

      check_error get(url)
    end

    # block a specified user
    def block_user(target)
      path = "/users/#{@name}/blocks/#{target}?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error put(url)
    end

    # unblock a specified user
    def unblock_user(target)
      path = "/users/#{@name}/blocks/#{target}?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error delete(url)
    end

    # a list of user objects who follow you
    def following(options = {})
      query = build_query_string(options)
      path = "/channels/#{@name}/follows"
      url = BASE_URL + path + query

      check_error get(url)
    end

    # a list of user objects that you are following
    def followed(options = {})
      query = build_query_string(options)
      path = "/users/#{@name}/follows/channels"
      url = BASE_URL + path + query

      check_error get(url)
    end

    # not working
    def follow_status(channel)
      path = "/users/#{@name}/follows/channels/#{channel}/?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error get(url)
    end

    # not working
    def subscriptions(options = {})
      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/channels/#{@name}/subscriptions"
      url = BASE_URL + path + query

      check_error get(url)
    end

    # not working
    def subscribed_to_channel(channel)
      path = "/channels/#{@name}/subscriptions/#{channel}?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error get(url)
    end

    private
      def get_user_info(access_token)
        path = "/user?oauth_token=#{access_token}"
        url = BASE_URL + path

        info = get(url)

        check_error(info)
      end

      def check_error(info)
        status = info[:body].headers["status"].split(' ').first.to_i
        case status
          when 400...500
            raise "#{status} status code"
          when 500...600
            raise "#{status} status code"
          else
           info[:body] # ignore, assume success and return successfully acquired data
        end
      end
  end
end