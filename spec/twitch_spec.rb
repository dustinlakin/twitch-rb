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
		expect(@t.getLink()).to eq "https://api.twitch.tv/kraken/oauth2/authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&scope=#{@scope_str}"
	end

	it 'should get user (not authenticated)' do
		@t = Twitch.new()
		expect(@t.getUser("day9")[:response]).to eq 200
	end

	it 'should get user (authenticated)' do
		@t = Twitch.new({:access_token => @access_token})
		expect(@t.getUser("day9")[:response]).to eq 200
	end

	it 'should get authenticated user' do
		@t = Twitch.new({:access_token => @access_token})
		expect(@t.getYourUser()[:response]).to eq 200
	end

	it 'should not get authenticated user when not authenticated' do
		@t = Twitch.new()
		expect(@t.getYourUser()).to eq false
	end

	it 'should get all teams' do
		@t = Twitch.new()
		expect(@t.getTeams()[:response]).to eq 200
	end

	it 'should get single team' do
		@t = Twitch.new()
		expect(@t.getTeam("eg")[:response]).to eq 200
	end


	it 'should get single channel' do
		@t = Twitch.new()
		expect(@t.getChannel("day9tv")[:response]).to eq 200
	end

	it 'should get your channel' do
		@t = Twitch.new({:access_token => @access_token})
		expect(@t.getYourChannel()[:response]).to eq 200
	end

	it 'should edit your channel' do
		@t = Twitch.new({:access_token => @access_token})
		expect(@t.editChannel("Changing API", "Diablo III")[:response]).to eq 200
	end

	# it 'should run a comercial on your channel' do
	# 	@t = Twitch.new({:access_token => @access_token})
	#   expect(@t.runCommercial("dustinlakin")[:response]).to eq 204
	# end

	it 'should get a single user stream' do
		@t = Twitch.new()
		expect(@t.getStream("nasltv")[:response]).to eq 200
	end

	it 'should get all streams' do
		@t = Twitch.new()
		expect(@t.getStreams()[:response]).to eq 200
	end

	it 'should get League of Legends streams with +' do
		@t = Twitch.new()
		expect(@t.getStreams({:game => "League+of+Legends"})[:response]).to eq 200
	end

	it 'should get League of Legends streams with spaces' do
		@t = Twitch.new()
		expect(@t.getStreams({:game => "League of Legends"})[:response]).to eq 200
	end

	it 'should get featured streams' do
		@t = Twitch.new()
		res = @t.getFeaturedStreams()

		expect(res[:response]).to eq 200
		expect(res[:body]["featured"].length).to eq 25
	end

	it 'should get more featured streams' do
		@t = Twitch.new()
		res = @t.getFeaturedStreams({:limit => 100})

		expect(res[:response]).to eq 200
		expect(res[:body]["featured"].length).to be > 25
	end
	
	it 'should get chat links' do
	  @t = Twitch.new()
	  expect(@t.getChatLinks("day9tv")[:response]).to eq 200
	end
	
	it 'should get chat badges' do
	  @t = Twitch.new()
	  expect(@t.getBadges("day9tv")[:response]).to eq 200
	end
	
	it 'should get chat emoticons' do
	  @t = Twitch.new()
	  expect(@t.getEmoticons()[:response]).to eq 200
	end
	
	it 'should get channel followers' do
	  @t = Twitch.new()
	  expect(@t.getFollowing("day9tv")[:response]).to eq 200
	end
	
	it 'should get channels followed by user' do
	  @t = Twitch.new()
	  expect(@t.getFollowed("day9")[:response]).to eq 200
	end
	
	it 'should get status of user following channel' do
	  @t = Twitch.new()
	  expect(@t.getFollowStatus("day9", "day9tv")[:response]).to eq 404
	end
	
	it 'should get ingests' do
	  @t = Twitch.new()
	  expect(@t.getIngests[:response]).to eq 200
	end
	
	it 'should get root' do
	  @t = Twitch.new()
	  expect(@t.getRoot[:response]).to eq 200
	end
	
	it 'should get your followed streams' do
	  @t = Twitch.new()
	  expect(@t.getYourFollowedStreams).to eq false
	end
	
	it 'should get your followed videos' do
	  @t = Twitch.new()
	  expect(@t.getYourFollowedVideos).to eq false
	end
	
	it 'should get top games' do
	  @t = Twitch.new()
	  expect(@t.getTopGames[:response]).to eq 200
	end
	
	it 'should get top videos' do
	  @t = Twitch.new()
	  expect(@t.getTopVideos[:response]).to eq 200
	end

	it 'should have a default adapter' do
		t = Twitch.new

		expect( t.adapter ).to eq(Twitch::Adapters::HTTPartyAdapter)
	end

	it 'should work with a different adapter (open-uri).' do
		require 'open-uri' 

		module Twitch
			module Adapters
				class OpenURIAdapter < BaseAdapter
					def self.request(method, url, options={})
						if (method == :get)
							ret = {}

							open(url) do |io|
								ret[:body] = JSON.parse(io.read)
								ret[:response] = io.status.first.to_i
							end

							ret
						end
					end
				end # class OpenURIAdapter
			end # module Adapters
		end # module Twitch

		t = Twitch.new adapter: Twitch::Adapters::OpenURIAdapter

		res = t.getFeaturedStreams

		expect( res[:response]          ).to eq 200
		expect( res[:body]["featured"].length ).to eq 25
	end

	it "should fall-back to the default adapter when passed an invalid adapter" do
		expect( Twitch.new( adapter: false         ).adapter ).to eq( Twitch::Adapters::DEFAULT_ADAPTER )
		expect( Twitch.new( adapter: 100           ).adapter ).to eq( Twitch::Adapters::DEFAULT_ADAPTER )
		expect( Twitch.new( adapter: :bad_constant ).adapter ).to eq( Twitch::Adapters::DEFAULT_ADAPTER )

		t = Twitch.new
		t.adapter = nil

		expect( t.adapter ).to eq( Twitch::Adapters::DEFAULT_ADAPTER )
	end

end
