module Twitch
  module Request
    def build_query_string(options)
      query = "?"
      options.each do |key, value|
        query += "#{key}=#{value.to_s.gsub(" ", "+")}&"
      end
      query = query[0...-1]
    end

    def get(url)
      @adapter.get(url)
    end

    def post(url, data)
      @adapter.post(url, :body => data)
    end

    def put(url, data={})
      @adapter.put(url, :body => data, :headers => {
          'Accept' => 'application/vnd.twitchtv.v3+json',
          'Content-Type' => 'application/json',
          
      })
    end
    
    def delete(url)
      @adapter.delete(url)
    end
  end
end
