## master

*   Remove `Twitch.new`, use `Twitch::Client.new`.
*   Use `twitch_oauth2` gem for authentication (parameters changed).
    Check `README` for additional info.
*   Add `tokens`, `access_token` and `refresh_token` getters.
*   Replace custom adapters and `HTTParty` with `Faraday` and its adapters.
*   Delete undocumented `channel_panels` and `chat_links` methods
    not from Kraken version.
*   Rename `edit_channel` to `update_channel`.
*   Add support of options (`stream_type`) for `stream`.
*   Add `retriable`: retry requests on fails.
*   Add `Twitch::ServerError` for 5xx HTTP errors, apply `retriable` to them.
*   Specify required Ruby version, 2.4, and support Ruby 3.
*   Use [`VCR`](https://relishapp.com/vcr/vcr/docs) (recorded HTTP requests)
    for tests.
*   Add [RuboCop](https://docs.rubocop.org/).
*   Add [EditorConfig](https://editorconfig.org/) file.
*   Increase max line length from 80 (previous RuboCop's default)
    to 100 (average between previous and new RuboCop's default, 120).
*   Replace `add_dependency` with more explicit `add_runtime_dependency` in gem spec.

## 0.1.3

*   Add options to `following` and `followed` methods.
*   Add `channel_panels` method.

## 0.1.2

*   Fix `Twitch::Client#unfollow` method name.
*   Allow `Twitch::Client#subscribed` method to receive query string options.

## 0.1.1

*   Allow to override `oauth_token` in options.

## 0.1.0

*   Replace `camelCase` method names with `snake_case`.
*   Remove `get_` prefix from method names.
*   Make `your_` prefix optional (e.g. `user` and `your_user` are equal).
