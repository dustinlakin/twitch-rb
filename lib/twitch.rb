require "curb"
require "json"

class Twitch
	def initialize
		@client_id = "k96gsxbp95dgpv9ck8wnzqcyhifqxv5"
		@secret_key = "9is2azmi3iw5r29ay7d8gvl4u4feeyg"
		@redirect_uri = "http://localhost:3000/auth"
		@scope = ["user_red", "channel_read"]

		@base_url = "https://api.twitch.tv/kraken"
		@access_token = nil
	end

	public

	def setAccessToken(token)
		@access_token = token
	end

	def getLink
		scope = ""
		@scope.each do |s|
			scope += s + " "
		end
		link = "https://api.twitch.tv/kraken/oauth2/authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&scope=#{scope}"
	end

	def auth(code)
		path = "/oauth2/token"
		url = @base_url + path
		post(url, {
			:client_id => @client_id,
			:client_secret => @secret_key,
			:grant_type => "authorization_code",
			:redirect_uri => @redirect_uri,
			:code => code
		})
	end



	# USER

	def getUser(user)
		path = "/users/"
		url = @base_url + path + user;
		get(url)
	end

	def getYourUser
		return false if !@access_token
		path = "/user?oauth_token=" + @access_token
		url = @base_url + path
		get(url)
	end



	# TEAMS

	def getTeams
		path = "/teams/"
		url = @base_url + path;
		get(url)
	end


	def getTeam(team_id)
		path = "/team/"
		url = @base_url + path;
		get(url)
	end


	# Channel

	def getChannel(channel)
		path = "/channels/"
		url = @base_url + path + channel;
		get(url)
	end


	def getYourChannel
		return false if !@access_token
		path = "/channel/"
		url = @base_url + path;
		get(url)
	end

	private

	def post(url, data)
		JSON.parse(Curl.post(url, data).body_str)
	end

	def get(url)
		JSON.parse(Curl.get(url).body_str)
	end

end