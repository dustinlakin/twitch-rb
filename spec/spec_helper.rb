# frozen_string_literal: true

require 'pry-byebug'

require 'simplecov'
SimpleCov.start

ENV['TWITCH_CLIENT_ID'] ||= ''
ENV['TWITCH_CLIENT_SECRET'] ||= ''
ENV['TWITCH_ACCESS_TOKEN'] ||= ''
ENV['TWITCH_REFRESH_TOKEN'] ||= ''

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "#{__dir__}/cassettes"
  config.default_cassette_options = { record_on_error: false }
  config.hook_into :faraday
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<CLIENT_ID>') do
    ENV['TWITCH_CLIENT_ID']
  end

  config.filter_sensitive_data('<CLIENT_SECRET>') do
    ENV['TWITCH_CLIENT_SECRET']
  end

  config.filter_sensitive_data('<ACTUAL_ACCESS_TOKEN>') do
    ENV['TWITCH_ACCESS_TOKEN']
  end

  config.filter_sensitive_data('<ACTUAL_REFRESH_TOKEN>') do
    ENV['TWITCH_REFRESH_TOKEN']
  end

  config.filter_sensitive_data('<CODE>') do |interaction|
    URI.decode_www_form(interaction.request.body).to_h['code']
  end

  config.filter_sensitive_data('<ACCESS_TOKEN>') do |interaction|
    if interaction.response.headers['content-type'].include? 'application/json'
      JSON.parse(interaction.response.body)['access_token']
    end
  end

  config.filter_sensitive_data('<REFRESH_TOKEN>') do |interaction|
    if interaction.response.headers['content-type'].include? 'application/json'
      JSON.parse(interaction.response.body)['refresh_token']
    end
  end
end

require_relative '../lib/twitch'

Retriable.configure do |config|
  # config.tries = 1
  config.base_interval = 0

  config.contexts.transform_values do |context|
    # context[:tries] = 1
    context[:base_interval] = 0
  end
end

# [Twitch, TwitchOAuth2].each do |lib|
#   lib::Client::CONNECTION
#     .response :logger, nil, { headers: true, bodies: true }
# end
