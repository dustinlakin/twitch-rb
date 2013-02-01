require "curb"
require "json"

class Twitch
	def initialize
		@clientId = "k96gsxbp95dgpv9ck8wnzqcyhifqxv5"
		@secretKey = "9is2azmi3iw5r29ay7d8gvl4u4feeyg"
		@redirectUri = "http://localhost:3000/auth"
		@baseUrl = "https://api.twitch.tv/kraken"
		@scope = ["user_red", "channel_read"]
	end

	public

	def getLink
		scope = ""
		@scope.each do |s|
			scope += s + " "
		end
		link = "https://api.twitch.tv/kraken/oauth2/authorize?response_type=code&client_id=#{@clientId}&redirect_uri=#{@redirectUri}&scope=#{scope}"
	end

	def auth(code)
		path = "/oauth2/token"
		url = @baseUrl + path
		http = Curl.post(url, 
			{
				:client_id => @clientId,
				:client_secret => @secretKey,
				:grant_type => "authorization_code",
				:redirect_uri => @redirectUri,
				:code => code
			})
		JSON.parse(http.body_str)
	end

	def getUser(user)
		path = "/users/"
		url = @baseUrl + path + user;
		http = Curl.get(url)
		JSON.parse(http.body_str)
	end



	private

	def post(url, code)


end