# Twitch API

This gem simplifies the Twitch-API for ruby users.


## Install

With Rails:

```ruby
#add to your Gemfile
gem 'twitch', '~> 0.1.0'
```

Just irb or pry:

```ruby
$ gem install twitch

irb > require 'twitch'
irb > @twitch = Twitch.new()
```

## Changes in 0.1.0 from 0.0.x

Listed below are some changes introduced in version 0.1.0 from 0.0.x. Some of the changes break backward compatibility with previous versions.

```
- Replaced camelCase method names with snake_case.
- Removed 'get_' prefix from method names.
- Made 'your_' prefix optional. (e.g. user() and your_user() are equal)
```

## Authorizing

Step 1: Get url for your application - (@scope is an array of permissions, like ["user\_read", "channel\_read", "user\_follows_edit"])

```ruby
@twitch = Twitch.new({
  client_id: @client_id,
  secret_key: @secret_key,
  redirect_uri: @redirect_uri,
  scope: @scope
})

@twitch.link
```

Step 2: Authenticate and get access_token (this is done on your @redirect\_url)

```ruby
@twitch = Twitch.new({
  client_id: @client_id,
  secret_key: @secret_key,
  redirect_uri: @redirect_uri,
  scope: @scope
})

@data = @twitch.auth(params[:code])
session[:access_token] = @data[:body]["access_token"]
```

Step 3: You can now use user token

```ruby
@twitch = Twitch.new access_token: session["access_token"]
@yourself = @twitch.your_user()
```

## Calls

Calls will return a Hash with :body for the content of the call and a :response

```ruby
@twitch.user "day9tv"
```

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

## Usage

### Users

```ruby
#does not require any access_token 
# @twitch = Twitch.new()
@twitch.user "day9tv"
```

----

```ruby
#requires access_token, use 
# @twitch = Twitch.new access_token: session["access_token"]
@twitch.your_user()

```

### Teams

```ruby
@twitch.teams()
```

----

```ruby
@twitch.team "eg"
```

### Channels

```ruby
@twitch.channel "lethalfrag"
```

```ruby
@twitch.channel_panels "lethalfrag"
```

----

```ruby
#Requires access_token
@twitch.your_channel
```

----

```ruby
# Requires access_token (and special scope for channel editing)
#   edit_channel(channelname, status, game)
#   arguments:
#    status (string)
#    game (string)

@twitch.edit_channel "ChannelName", "Ranked Solo Queue", "League of Legends"
```

----

```ruby
#Requires access_token (and special scope for channel commercials)
#   run_commercial(channel, length = 30)
#   arguments:
#    channel (string)
#    length (int)
#  *this is untested*

@twitch.run_commercial "lethalfrag", 30
```

### Follows

```@twitch.following 'esl_csgo'```

----

```@twitch.followed 'esl_csgo'```


### Streams

```ruby
@twitch.stream "lethalfrag"
```

----

```ruby
# getStreams(options = {})
# see Twitch-API for options

@twitch.streams
```

----
```ruby
# getFeaturedStreams(options = {})
# see Twitch-API for options
```
----
```ruby
@twitch.your_featured_streams
```
----
```ruby
#Requires access_token
@twitch.your_followed_streams
```

### Games

```ruby
@twitch.top_games
```

### Search


```ruby
# search_streams(options = {})
# see Twitch-API for options

@twitch.search_streams
```
----

```ruby
# search_games(options = {})
# see Twitch-API for options

@twitch.search_games
```

### Videos


```ruby
# get_channel_videos(channel, options = {})
# see Twitch-API for options

@twitch.channel_videos "lethalfrag"
```

----
```ruby
# get_video(video_id)

@twitch.video 12345
```

### Adapters


To allow the gem to use different HTTP libraries, you can define an Adapter:

```ruby
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
```

and then pass it into the Twitch class:

```ruby
@twitch = Twitch.new adapter: Twitch::Adapters::OpenURIAdapter

# or

@twitch = Twitch.new
@twitch.adapter = Twitch::Adapters::OpenURIAdapter
```

Adapters must be defined inside the Twitch::Adapters module, otherwise they will be considered invalid.
Any invalid adapter passed to the library will revert to the default adapter.

The default adapter is `Twitch::Adapters::HTTPartyAdapter` which uses the [HTTParty library](https://github.com/jnunemaker/httparty).

Feel free to contribute or add functionality!
