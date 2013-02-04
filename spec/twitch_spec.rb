require 'spec_helper'

describe Twitch do

	before(:each) do
		@client_id = ""
		@secret_key = ""
		@redirect_uri = "http://localhost:3000/auth"
		@scope = ["user_red", "channel_read", "channel_editor", "channel_commercial", "channel_stream", "user_blocks_edit"]
		@scope_str = ""
		@scope.each{ |s| @scope_str += s + " " }
		@access_token = ""
	end

	it 'should build accurate link' do
		@t = Twitch.new({
			:client_id => @client_id,
			:secret_key => @secret_key,
			:redirect_uri => @redirect_uri,
			:scope => ["user_red", "channel_read", "channel_editor", "channel_commercial", "channel_stream", "user_blocks_edit"]
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



end
