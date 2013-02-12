Twitch API
==========

This gem simplifies the Twitch-API for ruby users.



http://lak.in // http://twitter.com/dustinlakin


Install
----------------

With Rails:
    #add to your Gemfile
    gem 'twitch', '>= 0.0.2'


Just irb or pry:
    $ gem install twitch

    
    irb > require 'twitch'
    irb > @twitch = Twitch.new()


Authorizing
----------------

Step 1: Get url for your application - (@scope is an array of permissions, like ["user\_read", "channel\_read", "user\_follows_edit"])


    @twitch = Twitch.new({
      :client_id => @client_id,
      :secret_key => @secret_key,
      :redirect_uri => @redirect_uri,
      :scope => @scope
      })
    @twitch.getLink()

Step 2: Authenticate and get access_token (this is done on your @redirect\_url)

    @twitch = Twitch.new({
      :client_id => @client_id,
      :secret_key => @secret_key,
      :redirect_uri => @redirect_uri,
      :scope => @scope
      })
    @data = @twitch.auth(params[:code])
    session[:access_token] = @data[:body]["access_token"]

Step 3: You can now use user token

    @twitch = Twitch.new({ :access_token => session["access_token"]})
    @yourself = @twitch.getYourUser()




Calls
===========

Calls will return a Hash with :body for the content of the call and a :response

    user = "day9tv"
    @twitch.getUser(user)

returns:

    {
     :body=>
      {"display_name"=>"dustinlakin",
       "logo"=>nil,
       "created_at"=>"2011-12-18T18:42:09Z",
       "staff"=>false,
       "updated_at"=>"2013-02-11T23:48:11Z",
       "_id"=>26883731,
       "name"=>"dustinlakin",
       "_links"=>{"self"=>"https://api.twitch.tv/kraken/users/dustinlakin"}},
     :response=>200
    }




Users
-----
    #does not require any access_token 
    # @twitch = Twitch.new() 
    user = "day9tv"
    @twitch.getUser(user)

----
    #requires access_token, use 
    # @twitch = Twitch.new({ :access_token => session["access_token"]}))
    @twitch.getYourUser()



Teams
-----
    @twitch.getTeams()

----
    @twitch.getTeam("eg")


Channels
-----
    @twitch.getChannel("lethalfrag")

----
    #Requires access_token
    @twitch.getYourChannel()

----
    #Requires access_token (and special scope for channel editing)
    #   editChannel(status, game)
    #   arguments:
    #    status (string)
    #    game (string)
    
    @twitch.editChannel("Ranked Solo Queue", "League of Legends")

----

    #Requires access_token (and special scope for channel commercials)
    #   runCommercial(channel, length = 30)
    #   arguments:
    #    channel (string)
    #    length (int)
    #  *this is untested*

    @twitch.runCommercial("lethalfrag", 30)
    

Streams
-----
    @twitch.getStream("lethalfrag")

  ----
    # getStreams(options = {})
    # see Twitch-API for options

    @twitch.getStreams()

----
    # getFeaturedStreams(options = {})
    # see Twitch-API for options

----
    @twitch.getFeaturedStreams()

----
    #Requires access_token
    @twitch.getYourFollowedStreams()


Games
-----
    @twitch.getTopGames()


Search
-----

    # searchStreams(options = {})
    # see Twitch-API for options

    @twitch.searchStreams()

 ----
    # searchGames(options = {})
    # see Twitch-API for options

    @twitch.searchGames()


Videos
-----

    # getChannelVideos(channel, options = {})
    # see Twitch-API for options

    @twitch.getChannelVideos("lethalfrag")

 ----
    # getVideo(video_id)

    @twitch.getVideo(12312123)



Feel free to contribute or add functionality!