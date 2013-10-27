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

	def getLink
		scope = ""
		@scope.map!{ |s| s + '+'}
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

	# User

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

	# Teams

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
		return false if !@access_token
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

	def runCommercial(channel, length = 30)
		return false if !@access_token
		path = "/channels/#{channel}/commercial?oauth_token=#{@access_token}"
		url = @base_url + path
		post(url, {
			:length => length
		})
	end

	# Streams

	def getStream(stream_name)
		path = "/stream/#{stream_name}"
		url = @base_url + path;
		get(url)
	end

	def getStream(stream_name)
		path = "/streams/#{stream_name}"
		url = @base_url + path;
		get(url)
	end

	def getStreams(options = {})
		query = buildQueryString(options)
		path = "/streams"
		url =  @base_url + path + query
		get(url)
	end

	def getFeaturedStreams(options = {})
		query = buildQueryString(options)
		path = "/streams/featured"
		url = @base_url + path + query
		get(url)
	end

	def getSummeraizedStreams(options = {})
		query = buildQueryString(options)
		path = "/streams/summary"
		url = @base_url + path + query
		get(url)
	end

	def getYourFollowedStreams
		path = "/streams/followed?oauth_token=#{@access_token}"
		url = @base_url + path
		get(url)
	end

	#Games

	def getTopGames(options = {})
		query = buildQueryString(options)
		path = "/games/top"
		url = @base_url + path + query
		get(url)
	end

	#Search

	def searchStreams(options = {})
		query = buildQueryString(options)
		path = "/search/streams"
		url = @base_url + path + query
		get(url)
	end

	def searchGames(options = {})
		query = buildQueryString(options)
		path = "/search/games"
		url = @base_url + path + query
		get(url)
	end

	# Videos

	def getChannelVideos(channel, options = {})
		query = buildQueryString(options)
		path = "/channels/#{channel}/videos"
		url = @base_url + path + query
		get(url)
	end

	def getVideo(video_id)
		path = "/videos/#{video_id}/"
		url = @base_url + path
		get(url)
	end


	private

	def buildQueryString(options)
		query = "?"
		options.each do |key, value|
			query += "#{key}=#{value.to_s.gsub(" ", "+")}&"
		end
		query = query[0...-1]
	end

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