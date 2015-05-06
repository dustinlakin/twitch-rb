require 'spec_helper'

describe Twitch do

	before(:each) do
    @client_id = ""
    @secret_key = ""
    @redirect_uri = "http://localhost:3000/auth"
    @scope = ["user_read", "channel_read", "channel_editor", "channel_commercial", "channel_stream", "user_blocks_edit"]
    @scope_str = ""
    @scope.each{ |s| @scope_str += s + "+" }
    @access_token = ""
  end

	it 'should build accurate link' do
		@t = Twitch.new({
			:client_id => @client_id,
			:secret_key => @secret_key,
			:redirect_uri => @redirect_uri,
			:scope => ["user_read", "channel_read", "channel_editor", "channel_commercial", "channel_stream", "user_blocks_edit"]
			})
		@t.getLink().should == "https://api.twitch.tv/kraken/oauth2/authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&scope=#{@scope_str}"
	end

	it 'should get user (not authenticated)' do
		@t = Twitch.new()
		@t.getUser("day9")[:response].should == 200
	end

	it 'should get user (authenticated)' do
		@t = Twitch.new({:access_token => @access_token})
		@t.getUser("day9")[:response].should == 200
	end

	it 'should get authenticated user' do
		@t = Twitch.new({:access_token => @access_token})
		@t.getYourUser()[:response].should == 200
	end

	it 'should not get authenticated user when not authenticated' do
		@t = Twitch.new()
		@t.getYourUser().should == false
	end

	it 'should get all teams' do
		@t = Twitch.new()
		@t.getTeams()[:response].should == 200
	end

	it 'should get single team' do
		@t = Twitch.new()
		@t.getTeam("eg")[:response].should == 200
	end


	it 'should get single channel' do
		@t = Twitch.new()
		@t.getChannel("day9tv")[:response].should == 200
	end

	it 'should get your channel' do
		@t = Twitch.new({:access_token => @access_token})
		@t.getYourChannel()[:response].should == 200
	end

	it 'should edit your channel' do
		@t = Twitch.new({:access_token => @access_token})
		@t.editChannel("Changing API", "Diablo III")[:response].should == 200
	end

	# it 'should run a comercial on your channel' do
	# 	@t = Twitch.new({:access_token => @access_token})
	# 	@t.runCommercial("dustinlakin")[:response].should == 204
	# end

	it 'should get a single user stream' do
		@t = Twitch.new()
		@t.getStream("nasltv")[:response].should == 200
	end

	it 'should get all streams' do
		@t = Twitch.new()
		@t.getStreams()[:response].should == 200
	end

	it 'should get League of Legends streams with +' do
		@t = Twitch.new()
		@t.getStreams({:game => "League+of+Legends"})[:response].should == 200
	end

	it 'should get League of Legends streams with spaces' do
		@t = Twitch.new()
		@t.getStreams({:game => "League of Legends"})[:response].should == 200
	end

	it 'should get featured streams' do
		@t = Twitch.new()
		res = @t.getFeaturedStreams()
		res[:response].should == 200 && res[:body]["featured"].length.should == 25
	end

	it 'should get featured streams' do
		@t = Twitch.new()
		res = @t.getFeaturedStreams({:limit => 100})
		res[:response].should == 200 && res[:body]["featured"].length.should > 25
	end
	
	it 'should get chat links' do
	  @t = Twitch.new()
	  @t.getChatLinks("day9tv")[:response].should == 200
	end
	
	it 'should get chat badges' do
	  @t = Twitch.new()
	  @t.getBadges("day9tv")[:response].should == 200
	end
	
	it 'should get chat emoticons' do
	  @t = Twitch.new()
	  @t.getEmoticons()[:response].should == 200
	end
	
	it 'should get channel followers' do
	  @t = Twitch.new()
	  @t.getFollowing("day9tv")[:response].should == 200
	end
	
	it 'should get channels followed by user' do
	  @t = Twitch.new()
	  @t.getFollowed("day9")[:response].should == 200
	end
	
	it 'should get status of user following channel' do
	  @t = Twitch.new()
	  @t.getFollowStatus("day9", "day9tv")[:response].should == 404
	end
	
	it 'should get ingests' do
	  @t = Twitch.new()
	  @t.getIngests[:response].should == 200
	end
	
	it 'should get root' do
	  @t = Twitch.new()
	  @t.getRoot[:response].should == 200
	end
	
	it 'should get your followed streams' do
	  @t = Twitch.new()
	  @t.getYourFollowedStreams.should == false
	end
	
	it 'should get your followed videos' do
	  @t = Twitch.new()
	  @t.getYourFollowedVideos.should == false
	end
	
	it 'should get top games' do
	  @t = Twitch.new()
	  @t.getTopGames[:response].should == 200
	end
	
	it 'should get top videos' do
	  @t = Twitch.new()
	  @t.getTopVideos[:response].should == 200
	end

end
