require "curb"
require "json"

class Twitch
	def initialize(options = {})
		@client_id = options[:client_id] || nil
		@secret_key = options[:secret_key] || nil
		@redirect_uri = options[:redirect_uri] || nil
		@scope = options[:scope] || nil
		@access_token = options[:access_token] || nil

		@base_url = "https://api.twitch.tv/kraken"
	end

	public

	def setTestingDefaults
		@client_id = "k96gsxbp95dgpv9ck8wnzqcyhifqxv5"
		@secret_key = "9is2azmi3iw5r29ay7d8gvl4u4feeyg"
		@redirect_uri = "http://localhost:3000/auth"
		@scope = ["user_red", "channel_read", "channel_editor", "channel_commercial", "channel_stream", "user_blocks_edit"]
		@access_token = "1d6lcvunb152ccoxlzuxesh7u337m2a"
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
		path = "/user?oauth_token=#{@access_token}"
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
		path = "/teams/"
		url = @base_url + path + team_id;
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
		path = "/channel?oauth_token=#{@access_token}"
		url = @base_url + path;
		get(url)
	end

	def editChannel(status, game)
		path = "/channels/dustinlakin/?oauth_token=#{@access_token}"
		url = @base_url + path
		data = {
			:channel =>{
				:game => game,
				:status => status
			}
		}
		put(url, data)
	end

	private

	def post(url, data)
		JSON.parse(Curl.post(url, data).body_str)
		c = Curl.post(url, data)
		{:body => JSON.parse(c.body_str), :response => c.response_code}
	end

	def get(url)
		c = Curl.get(url)
		{:body => JSON.parse(c.body_str), :response => c.response_code}
	end

	def put(url, data)
		c = Curl.put(url,data.to_json) do |curl|
			curl.headers['Accept'] = 'application/json'      
			curl.headers['Content-Type'] = 'application/json'      
			curl.headers['Api-Version'] = '2.2'      
			end
		{:body => JSON.parse(c.body_str), :response => c.response_code}
	end


end