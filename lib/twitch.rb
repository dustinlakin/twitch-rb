require "httparty"

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
		@scope.each { |s| scope += s + '+' }
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
	
	def getEditors(channel)
	  return false if !@access_token
		path = "/channels/#{channel}/editors?oauth_token=#{@access_token}"
		url = @base_url + path;
		get(url)
	end

  # TODO: Add ability to set delay, which is only available for partered channels
	def editChannel(channel, status, game)
		return false if !@access_token
		path = "/channels/#{channel}/?oauth_token=#{@access_token}"
		url = @base_url + path
		data = {
			:channel =>{
				:game => game,
				:status => status
			}
		}
		put(url, data)
	end
	
	def resetKey(channel)
    return false if !@access_token
    path = "/channels/#{channel}/stream_key?oauth_token=#{@access_token}"
    url = @base_url + path
    delete(url)
  end

  def followChannel(username, channel)
    return false if !@access_token
    path = "/users/#{username}/follows/channels/#{channel}?oauth_token=#{@access_token}"
    url = @base_url + path
    put(url)
  end
  
  def followChannel(username, channel)
    return false if !@access_token
    path = "/users/#{username}/follows/channels/#{channel}?oauth_token=#{@access_token}"
    url = @base_url + path
    delete(url)
  end

	def runCommercial(channel, length = 30)
		return false if !@access_token
		path = "/channels/#{channel}/commercial?oauth_token=#{@access_token}"
		url = @base_url + path
		post(url, {
			:length => length
		})
	end
	
	def getChannelTeams(channel)
	  return false if !@access_token
		path = "/channels/#{channel}/teams?oauth_token=#{@access_token}"
		url = @base_url + path;
		get(url)
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

	def getYourFollowedStreams(options = {})
	  return false if !@access_token
    query = buildQueryString(options)
		path = "/streams/followed?oauth_token=#{@access_token}"
		url = @base_url + path + query
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
	
	def searchChannels(options = {})
		query = buildQueryString(options)
		path = "/search/channels"
		url = @base_url + path + query
		get(url)
	end

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

  def isSubscribed(username, channel, options = {})
    query = buildQueryString(options)
    path = "/users/#{username}/subscriptions/#{channel}?oauth_token=#{@access_token}"
    url = @base_url + path + query
    get(url)
  end
  
  def getYourFollowedVideos(options ={})
    return false if !@access_token
    query = buildQueryString(options)
		path = "/videos/followed?oauth_token=#{@access_token}"
		url = @base_url + path + query
		get(url)
	end
	
	def getTopVideos(options = {})
		query = buildQueryString(options)
		path = "/videos/top"
		url = @base_url + path + query
		get(url)
	end
  
  # Blocks
  
  def getBlocks(username, options = {})
    query = buildQueryString(options)
    path = "/users/#{username}/blocks?oauth_token=#{@access_token}"
    url = @base_url + path + query
    get(url)
  end
  
  def blockUser(username, target)
    return false if !@access_token
    path = "/users/#{username}/blocks/#{target}?oauth_token=#{@access_token}"
    url = @base_url + path
    put(url)
  end
  
  def unblockUser(username, target)
    return false if !@access_token
    path = "/users/#{username}/blocks/#{target}?oauth_token=#{@access_token}"
    url = @base_url + path
    delete(url)
  end
  
  # Chat
  
  def getChatLinks(channel)
    path = "/chat/"
		url = @base_url + path + channel;
		get(url)
  end
  
  def getBadges(channel)
    path = "/chat/#{channel}/badges"
		url = @base_url + path;
		get(url)
  end
  
  def getEmoticons()
    path = "/chat/emoticons"
		url = @base_url + path;
		get(url)
  end
  
  # Follows
  
  def getFollowing(channel)
    path = "/channels/#{channel}/follows"
		url = @base_url + path;
		get(url)
  end
  
  def getFollowed(username)
    path = "/users/#{username}/follows/channels"
		url = @base_url + path;
		get(url)
  end
  
  def getFollowStatus(username, channel)
    path = "/users/#{username}/follows/channels/#{channel}/?oauth_token=#{@access_token}"
		url = @base_url + path;
		get(url)
  end
  
  # Ingests
  
  def getIngests()
		path = "/ingests"
		url = @base_url + path
		get(url)
	end
	
	# Root
	
  def getRoot()
		path = "/?oauth_token=#{@access_token}"
		url = @base_url + path
		get(url)
	end
	
	# Subscriptions
	
	def getSubscribed(channel)
	  return false if !@access_token
		path = "/channels/#{channel}/subscriptions?oauth_token=#{@access_token}"
		url = @base_url + path
		get(url)
	end
	
	def isSubscirbedToChannel(username, channel)
	  return false if !@access_token
		path = "/channels/#{channel}/subscriptions/#{username}?oauth_token=#{@access_token}"
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
		response_data = HTTParty.post(url, :body => data)
		{
			:body => response_data,
			:response => response_data.code
		}
	end

	def get(url)
		c = HTTParty.get(url)
		{:body => c, :response => c.code}
	end

	def put(url, data={})
		c = HTTParty.put(url, :body => data, :headers => {
				'Accept' => 'application/json',
				'Content-Type' => 'application/json',
				'Api-Version' => '2.2'
		})
		{:body => c, :response => c.code}
	end
	
	def delete(url)
		c = HTTParty.delete(url)
		{:body => c, :response => c.code}
	end
end
