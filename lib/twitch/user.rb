module Twitch
  # I want to keep this class separate from the rest of the code so it will not break
  # from changes in other classes/modules
  # That is why I have chosen to include items that should normally not belong here e.g. BASE_URL
  class User
    
    BASE_URL = "https://api.twitch.tv/kraken".freeze

    def initialize(access_token)
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

    private
      def get_user_info(access_token)

        path = "/user?oauth_token=#{access_token}"
        url = BASE_URL + path

        info = get(url)

        status = info[:body].headers["status"].split(' ').first.to_i

        case status
          when 400...500
            raise "User error... \nyou are doing something, that you are not supposed to do"
          when 500...600
            raise "Server error... \n"
          else
            # ignore, assume success
        end

        info[:body]
      end
  end
end