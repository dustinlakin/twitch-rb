# frozen_string_literal: true

describe Twitch::Client do
  subject(:client) do
    described_class.new(
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      scopes: scopes,
      access_token: access_token,
      refresh_token: refresh_token
    )
  end

  let(:client_id) { ENV['TWITCH_CLIENT_ID'] }
  let(:client_secret) { ENV['TWITCH_CLIENT_SECRET'] }
  let(:redirect_uri) { 'http://localhost' }

  let(:scopes) do
    %w[
      user:read:email
      bits:read
      user_read
      channel_read
      channel_editor
      channel_commercial
      channel_stream
      user_blocks_edit
    ]
  end
  let(:scope_string) { scopes.join(' ') }

  let(:user_id) { ENV['TWITCH_USER_ID'] }
  let(:access_token) { ENV['TWITCH_ACCESS_TOKEN'] }
  let(:refresh_token) { ENV['TWITCH_REFRESH_TOKEN'] }

  let(:name) { a_string_matching(/^\w+$/) }
  let(:game) { String }
  let(:language) { a_string_matching(/^[a-z]{2}$/) }
  let(:locale) { a_string_matching(/^[a-z]{2}-[a-z]{2}$/) }

  let(:expected_team) do
    {
      _id: a_value > 0,
      created_at: Time,
      display_name: String,
      info: String,
      name: name,
      updated_at: Time
    }
  end

  let(:expected_user) do
    {
      _id: a_string_matching(/^\d+$/),
      created_at: Time,
      display_name: name,
      name: name,
      updated_at: Time
    }
  end

  let(:expected_channel) do
    expected_user.merge(
      broadcaster_software: String,
      broadcaster_type: String,
      description: String,
      followers: a_value >= 0,
      language: language,
      mature: boolean,
      partner: boolean,
      url: a_string_matching(%r{^https://www\.twitch\.tv/\w+$}),
      views: a_value >= 0
    )
  end

  let(:expected_images) do
    {
      large: String,
      medium: String,
      small: String,
      template: String
    }
  end

  let(:expected_stream_or_video) do
    {
      _id: a_value > 0,
      channel: a_hash_including(
        expected_channel.merge(_id: Integer)
      ),
      created_at: Time,
      game: game,
      preview: expected_images
    }
  end

  let(:expected_stream) do
    expected_stream_or_video.merge(
      average_fps: a_value >= 0,
      broadcast_platform: 'live',
      delay: a_value >= 0,
      stream_type: 'live',
      video_height: a_value > 0,
      viewers: a_value >= 0
    )
  end

  let(:expected_body_with_streams) do
    {
      streams: a_collection_including(
        a_hash_including(expected_stream)
      )
    }
  end

  let(:expected_video) do
    expected_stream_or_video.merge(
      _id: a_string_matching(/^v\d+$/),
      language: language,
      length: a_value > 0,
      published_at: Time,
      status: String,
      title: String,
      url: String,
      views: a_value >= 0
    )
  end

  let(:response_descriptions) { %w[#body #status #success?] }

  def example_group_descriptions(example_group)
    example_group_description = example_group.description
    example_group_description = nil if response_descriptions.include?(example_group_description)
    return if example_group_description == described_class.name

    [send(__method__, example_group.superclass), example_group_description]
      .compact
  end

  around do |example|
    cassette_name =
      example_group_descriptions(example.example_group)
        .join('/').delete('#?').downcase.tr(' ', '_')
    VCR.use_cassette(cassette_name) do
      example.run
    end
  end

  shared_examples 'success' do
    subject { response.success? }

    it { is_expected.to be true }
  end

  shared_examples 'correct behavior with actual or outdated access_token' do
    context 'with actual access_token' do
      include_examples 'correct behavior'
    end

    context 'with outdated access_token' do
      let(:access_token) { '9y7bf00r4fof71czggal1e2wlo50q3' }

      context 'with refresh_token' do
        include_examples 'correct behavior'
      end

      context 'without refresh_token' do
        let(:refresh_token) { nil }

        it do
          expect { response }.to raise_error(
            TwitchOAuth2::Error, 'missing refresh token'
          )
        end
      end
    end
  end

  shared_examples 'correct behavior with retries' do
    context 'with connection timed out errors' do
      before do
        connection = client.instance_variable_get(:@connection)

        ## https://github.com/lostisland/faraday/blob/c26df87/lib/faraday/connection.rb#L195-L204
        requested_times = 0
        allow(connection).to receive(:run_request).and_wrap_original do |m, *args|
          requested_times += 1

          raise timed_out_error if requested_times <= number_of_fails

          m.call(*args)
        end
      end

      let(:timed_out_error) do
        Errno::ETIMEDOUT.new('connect(2) for "api.twitch.tv" port 443')
      end

      context 'when fails less than retries' do
        let(:number_of_fails) { Retriable.config.contexts[:twitch][:tries] - 1 }

        include_examples 'correct behavior'
      end

      context 'when fails more than retries' do
        let(:number_of_fails) { Retriable.config.contexts[:twitch][:tries] + 1 }

        it do
          expect { response }.to raise_error timed_out_error
        end
      end
    end

    context 'with 5xx HTTP errors' do
      before do
        connection = client.instance_variable_get(:@connection)

        ## `connection.adapter` is a class
        allow(connection.adapter).to receive(:build).and_wrap_original do |build_m, *build_args|
          adapter = build_m.call(*build_args)

          requested_times = 0

          # rubocop:disable Metrics/ParameterLists
          allow(adapter).to receive(:save_response).and_wrap_original do |
            save_response_m, env, status, body, headers, *save_response_args, &block
          |
            requested_times += 1

            save_response_m.call(
              env,
              requested_times > number_of_fails ? status : error_status,
              body,
              headers,
              *save_response_args,
              &block
            )
          end
          # rubocop:enable Metrics/ParameterLists

          adapter
        end
      end

      let(:error_status) { 503 }

      context 'when fails less than retries' do
        let(:number_of_fails) { Retriable.config.contexts[:twitch][:tries] - 1 }

        include_examples 'correct behavior'
      end

      context 'when fails more than retries' do
        let(:number_of_fails) { Retriable.config.contexts[:twitch][:tries] + 1 }

        it do
          expect { response }.to raise_error Twitch::ServerError, "Server Error #{error_status}"
        end
      end
    end
  end

  shared_examples 'correct behavior for HTML response' do
    context 'with HTML responses' do
      let(:response_body) do
        <<~HTML
          <html>
            <head>
              <title>Test</title>
            </head>
            <body>
              <h1>Hello, world!</h1>
            </body>
          </html>
        HTML
      end

      before do
        connection = client.instance_variable_get(:@connection)

        allow(connection.adapter).to receive(:build).and_wrap_original do |build_m, *build_args|
          adapter = build_m.call(*build_args)

          # rubocop:disable Metrics/ParameterLists
          allow(adapter).to receive(:save_response).and_wrap_original do |
            save_response_m, env, status, _body, headers, *save_response_args, &block
          |
            save_response_m.call(
              env, status, response_body, headers, *save_response_args
            ) do |response_headers|
              block.call response_headers
              response_headers['content-type'] = 'text/html; charset=UTF-8'
            end
          end
          # rubocop:enable Metrics/ParameterLists

          adapter
        end
      end

      describe 'response.body' do
        subject { response.body }

        it { is_expected.to eq response_body }
      end
    end
  end

  describe '#user' do
    subject(:response) { client.user(user_id) }

    context 'with argument' do
      let(:user_id) { '44322889' }
      let(:name) { 'dallas' }

      shared_examples 'correct behavior' do
        include_examples 'success'

        describe '#body' do
          subject { response.body }

          it { is_expected.to include expected_user }
        end
      end

      include_examples 'correct behavior with retries'

      include_examples 'correct behavior for HTML response'
    end

    context 'without argument' do
      let(:user_id) { nil }
      let(:name) { a_string_matching(/^\w+$/) }

      shared_examples 'correct behavior' do
        include_examples 'success'

        describe '#body' do
          subject { response.body }

          it { is_expected.to include expected_user }
        end
      end

      include_examples 'correct behavior with actual or outdated access_token'
    end
  end

  describe '#teams' do
    subject(:response) { client.teams }

    include_examples 'success'

    describe '#body' do
      subject(:body) { response.body }

      it do
        expect(body).to match(
          teams: a_collection_including(
            a_hash_including(expected_team)
          )
        )
      end
    end
  end

  describe '#team' do
    subject(:response) { client.team(team) }

    let(:team) { 'eg' }

    include_examples 'success'

    describe '#body' do
      subject(:body) { response.body }

      it { is_expected.to include expected_team }
    end
  end

  describe '#channel' do
    subject(:response) { client.channel(channel_id) }

    context 'with argument' do
      let(:channel_id) { '44322889' }

      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to include expected_channel }
      end
    end

    context 'without argument' do
      let(:channel_id) { nil }

      shared_examples 'correct behavior' do
        include_examples 'success'

        describe '#body' do
          subject(:body) { response.body }

          it { is_expected.to include expected_channel }
        end
      end

      include_examples 'correct behavior with actual or outdated access_token'
    end
  end

  describe '#update_channel' do
    subject(:response) do
      client.update_channel(user_id, status: status, game: game)
    end

    let(:status) { 'Changing API' }
    let(:game) { 'Diablo III' }

    shared_examples 'correct behavior' do
      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        let(:expected_body) do
          expected_channel.merge(
            game: game,
            status: status
          )
        end

        it { is_expected.to include expected_body }
      end
    end

    include_examples 'correct behavior with actual or outdated access_token'
  end

  # describe '#run_commercial' do
  #   subject { super().run_commercial(channel) }
  #
  #   it { is_expected.to eq 200 }
  # end

  describe '#stream' do
    subject(:response) { client.stream(channel_id) }

    let(:channel_id) { '44741426' }

    include_examples 'success'

    describe '#body' do
      subject(:body) { response.body }

      it { is_expected.to match stream: a_hash_including(expected_stream) }
    end
  end

  describe '#streams' do
    subject(:response) { client.streams(options) }

    context 'without options' do
      let(:options) { {} }

      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to match expected_body_with_streams }
      end
    end

    context 'with game' do
      let(:game) { 'League of Legends' }
      let(:options) { { game: game } }

      let(:expected_stream) { super().merge(game: game) }

      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to match expected_body_with_streams }
      end
    end
  end

  describe '#featured_streams' do
    subject(:response) { client.featured_streams(options) }

    let(:options) { { limit: limit }.compact }

    context 'without limit' do
      let(:limit) { nil }

      include_examples 'success'

      describe 'count of items in response' do
        subject { response.body[:featured].count }

        let(:response_descriptions) { super().push self.class.description }

        it { is_expected.to eq 25 }
      end
    end

    context 'with limit' do
      let(:limit) { 33 }

      include_examples 'success'

      describe 'count of items in response' do
        subject { response.body[:featured].count }

        let(:response_descriptions) { super().push self.class.description }

        it { is_expected.to eq limit }
      end
    end
  end

  describe '#badges' do
    subject(:response) { client.badges(channel_id) }

    let(:channel_id) { '44322889' }

    include_examples 'success'

    describe '#body' do
      subject(:body) { response.body }

      def link_to_file(ext)
        a_string_matching(%r{^https?://[\w\-./]+\.#{ext}$})
      end

      let(:link_to_png) { link_to_file('png') }
      let(:link_to_svg) { link_to_file('svg') }

      let(:typical_links) do
        {
          alpha: link_to_png,
          image: link_to_png,
          svg: link_to_svg
        }
      end

      let(:expected_body) do
        {
          admin: typical_links,
          broadcaster: typical_links,
          global_mod: typical_links,
          mod: typical_links,
          staff: typical_links,
          turbo: typical_links
        }
      end

      it { is_expected.to include expected_body }
    end
  end

  ## > Caution: This endpoint returns a large amount of data.
  ## https://dev.twitch.tv/docs/v5/reference/chat#get-all-chat-emoticons

  # describe '#emoticons' do
  #   subject(:response) { client.emoticons }
  #
  #   include_examples 'success'
  #
  #   describe '#body' do
  #     subject(:body) { response.body }
  #
  #     let(:expected_emoticon) do
  #       {
  #         id: a_value > 0,
  #         regex: String,
  #         images: a_collection_including(
  #           a_hash_including(
  #             width: a_value > 0,
  #             height: a_value > 0,
  #             url: String,
  #             emoticon_set: a_value > 0
  #           )
  #         )
  #       }
  #     end
  #
  #     it do
  #       expect(body).to include(
  #         emoticons: a_collection_including(
  #           a_hash_including(expected_emoticon)
  #         )
  #       )
  #     end
  #   end
  # end

  describe '#following' do
    subject(:response) { client.following(channel_id, options) }

    let(:channel_id) { '44322889' }

    let(:expected_body) do
      {
        _total: a_value > 0,
        follows: a_collection_including(
          created_at: Time,
          notifications: boolean,
          user: a_hash_including(expected_user)
        )
      }
    end

    context 'without options' do
      let(:options) { {} }

      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to include expected_body }
      end
    end

    context 'with options' do
      let(:options) { { offset: 25, limit: 25 } }

      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to include expected_body }
      end
    end
  end

  describe '#followed' do
    subject(:response) { client.followed(user_id) }

    let(:user_id) { '44322889' }

    let(:expected_body) do
      {
        _total: a_value > 0,
        follows: a_collection_including(
          created_at: Time,
          notifications: boolean,
          channel: a_hash_including(expected_channel)
        )
      }
    end

    context 'without options' do
      let(:options) { {} }

      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to include expected_body }
      end
    end

    context 'with options' do
      let(:options) { { offset: 25, limit: 25 } }

      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to include expected_body }
      end
    end
  end

  describe '#follow_status' do
    subject(:response) { client.follow_status(user_id, channel_id) }

    context 'when follows' do
      let(:user_id) { '117474239' }
      let(:channel_id) { '128644134' }

      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        let(:expected_body) do
          {
            created_at: Time,
            notifications: boolean,
            channel: a_hash_including(
              expected_channel.merge(_id: a_value > 0)
            )
          }
        end

        it { is_expected.to match expected_body }
      end
    end

    context 'when does not follow' do
      let(:user_id) { '44322889' }
      let(:channel_id) { '129454141' }

      describe '#status' do
        subject { response.status }

        it { is_expected.to eq 404 }
      end

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to include status: 404, error: 'Not Found' }
      end
    end
  end

  describe '#ingests' do
    subject(:response) { client.ingests }

    include_examples 'success'

    describe '#body' do
      subject(:body) { response.body }

      let(:expected_ingest) do
        {
          _id: a_value > 0,
          availability: Float,
          default: boolean,
          name: String,
          url_template: String
        }
      end

      it do
        expect(body).to match(
          ingests: a_collection_including(
            expected_ingest
          )
        )
      end
    end
  end

  describe '#root' do
    subject(:response) { client.root }

    include_examples 'success'

    describe '#body' do
      subject(:body) { response.body }

      let(:expected_body) do
        {
          token: {
            authorization: {
              created_at: Time,
              scopes: scopes.sort,
              updated_at: Time
            },
            client_id: client_id,
            expires_in: Integer,
            user_id: user_id,
            user_name: name,
            valid: boolean
          }
        }
      end

      it { is_expected.to match expected_body }
    end
  end

  describe '#followed_streams' do
    subject(:response) { client.followed_streams }

    shared_examples 'correct behavior' do
      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it { is_expected.to match expected_body_with_streams }
      end
    end

    include_examples 'correct behavior with actual or outdated access_token'
  end

  describe '#followed_videos' do
    subject(:response) { client.followed_videos }

    shared_examples 'correct behavior' do
      include_examples 'success'

      describe '#body' do
        subject(:body) { response.body }

        it do
          expect(body).to match(
            videos: a_collection_including(
              a_hash_including(expected_video)
            )
          )
        end
      end
    end

    include_examples 'correct behavior with actual or outdated access_token'
  end

  describe '#top_games' do
    subject(:response) { client.top_games }

    include_examples 'success'

    describe '#body' do
      subject(:body) { response.body }

      let(:expected_body) do
        {
          _total: a_value >= 0,
          top: a_collection_including(
            channels: a_value >= 0,
            game: a_hash_including(
              _id: a_value > 0,
              locale: locale,
              localized_name: String,
              logo: expected_images,
              name: String
            ),
            viewers: a_value >= 0
          )
        }
      end

      it { is_expected.to match expected_body }
    end
  end

  describe '#top_videos' do
    subject(:response) { client.top_videos }

    include_examples 'success'

    describe '#body' do
      subject(:body) { response.body }

      it do
        expect(body).to match(
          vods: a_collection_including(
            a_hash_including(expected_video)
          )
        )
      end
    end
  end
end
