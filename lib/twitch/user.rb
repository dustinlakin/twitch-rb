module Twitch
  # I want to keep this class separate from the rest of the code so it will not break
  # from changes in other classes/modules
  # That is why I have chosen to include items that should normally not belong here e.g. BASE_URL
  #
  # Features:
  #  1. Error checking
  #  2. Intuitive queries
  #
  # Issues:
  #  1. Need tests... Something is bound to be incorrect in this pile of code
  #
  # Methods:
    # editors
    # edit_channel
    # reset_key
    # follow_channel
    # unfollow_channel
    # run_commercial
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

    # returns a list of user objects who are editors of the channel
    def editors
      path = "/channels/#{@name}/editors?oauth_token=#{@access_token}"
      url = BASE_URL + path

      info = get(url)

      check_error(info)
    end

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

    def reset_key
      path = "/channels/#{@name}/stream_key?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error(delete(url))
    end

    def follow_channel(channel)
      path = "/users/#{@name}/follows/channels/#{channel}?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error put(url)
    end

    def unfollow_channel(channel)
      path = "/users/#{@name}/follows/channels/#{channel}?oauth_token=#{@access_token}"
      url = BASE_URL + path
      check_error delete(url)
    end

    def run_commercial(length = 30)
      path = "/channels/#{@name}/commercial?oauth_token=#{@access_token}"
      url = BASE_URL + path
      info = post(url, {:length => length})

      check_error info
    end

    def channel_teams
      path = "/channels/#{@name}/teams?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error get(url)
    end

    def subscribed?(channel, options = {})
      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/users/#{@name}/subscriptions/#{channel}"
      url = BASE_URL + path + query

      check_error get(url)
    end

    def blocks(options = {})
      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/users/#{@name}/blocks"
      url = BASE_URL + path + query

      check_error get(url)
    end

    def block_user(target)
      path = "/users/#{@name}/blocks/#{target}?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error put(url)
    end

    def unblock_user(target)
      return false unless @access_token

      path = "/users/#{@name}/blocks/#{target}?oauth_token=#{@access_token}"
      url = BASE_URL + path
      check_error delete(url)
    end

    def following(options = {})
      query = build_query_string(options)
      path = "/channels/#{@name}/follows"
      url = BASE_URL + path + query

      check_error get(url)
    end

    def followed(options = {})
      query = build_query_string(options)
      path = "/users/#{@name}/follows/channels"
      url = BASE_URL + path + query

      check_error get(url)
    end

    def follow_status(channel)
      path = "/users/#{@name}/follows/channels/#{channel}/?oauth_token=#{@access_token}"
      url = BASE_URL + path

      check_error get(url)
    end

    def subscriptions(options = {})
      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/channels/#{@name}/subscriptions"
      url = BASE_URL + path + query

      check_error get(url)
    end

    def subscribed_to_channel(channel)
      return false unless @access_token

      path = "/channels/#{channel}/subscriptions/#{@name}?oauth_token=#{@access_token}"
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
            raise "User error... \nyou are doing something, that you are not supposed to do"
          when 500...600
            raise "Server error... \n"
          else
           info[:body] # ignore, assume success and return successfully acquired data
        end
      end
  end
end