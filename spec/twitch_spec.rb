require 'spec_helper'

describe Twitch do

	before(:each) do
		@client_id = "k96gsxbp95dgpv9ck8wnzqcyhifqxv5"
		@secret_key = "9is2azmi3iw5r29ay7d8gvl4u4feeyg"
		@redirect_uri = "http://localhost:3000/auth"
		@scope = ["user_red", "channel_read", "channel_editor", "channel_commercial", "channel_stream", "user_blocks_edit"]
		@scope_str = ""
		@scope.each{ |s| @scope_str += s + " " }
		@access_token = "1d6lcvunb152ccoxlzuxesh7u337m2a"
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
		@t.editChannel("testing api", "Diablo III")[:response].should == 200
	end

end
